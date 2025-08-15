## 12 Million trades Updates in 5 min batch estimates

### Baseline numbers

* Total trades = **12,000,000**
* Window = **5 minutes = 300 s**
* Total throughput required = **12,000,000 / 300 = 40,000 updates/sec**
* With **18 threads**, each thread must do:

  ```
  40,000 / 18 ≈ 2,222.22 updates/sec (≈ 2.22k/s)
  ```
* Records per thread overall:

  ```
  12,000,000 / 18 = 666,666.67 records ≈ 666,667 records/thread
  ```

---

### Practical batch-size table (examples)

For a given commit batch size `B`, below are: time to complete that batch per thread, number of batches each thread must do, and commit rate (per-thread and total):

| Batch size (rows) | Time per batch per thread | Batches / thread (total) | Commits/sec / thread | Commits/sec total |
| ----------------: | ------------------------: | -----------------------: | -------------------: | ----------------: |
|               100 |                   0.045 s |                 6,666.67 |              22.2222 |             400.0 |
|               500 |                   0.225 s |                 1,333.33 |               4.4444 |              80.0 |
|              1000 |                    0.45 s |                   666.67 |               2.2222 |              40.0 |
|              2000 |                     0.9 s |                   333.33 |               1.1111 |              20.0 |
|              5000 |                    2.25 s |                   133.33 |              0.44444 |               8.0 |
|             10000 |                     4.5 s |                    66.67 |              0.22222 |               4.0 |
|             50000 |                    22.5 s |                    13.33 |             0.044444 |               0.8 |

(Computed from: per-thread rate ≈ **2,222.22 updates/s**.)

---

### How to pick the right batch size — tradeoffs

* **Very small batches (100–500)**

    * Pros: short lock-hold times, easier to avoid long lock waits and deadlocks.
    * Cons: lots of commits → many fsyncs / log flushes unless DB2 groups commits; high commit overhead (e.g., 400 commits/sec systemwide at 100 B).
* **Medium batches (1k–5k)** — *recommended starting point*

    * Good balance. Example: **1k batch → 0.45s per batch per thread**, **40 commits/sec total**.
    * Low-ish commit rate (40/s) that DB2 group-commit mechanisms can handle, while keeping lock-hold short.
* **Large batches (10k–50k)**

    * Pros: fewer commits and less group-commit pressure.
    * Cons: long lock-hold per batch (4.5s–22.5s), greater risk of lock escalation or page-latch contention, larger log spikes.

**Recommendation:** start with **1,000–5,000 row batches**. My preference: **1,000** to begin (fast per-batch time, manageable commit rate). If log system and disk prove capable, you could test 2k–5k to reduce commit frequency.

---

### Additional recommendations to meet the SLA reliably

1. **Disjoint key ranges per thread** — ensure each thread updates a non-overlapping logical key range (you already do; keep it strict).
2. **Consistent update ordering** — sort each thread’s batch by PK (or clustering key) to minimize hot-page collisions.
3. **Index strategy** — drop non-essential indexes before run; if impossible, ensure updates don’t touch indexed columns where feasible.
4. **Increase DB2 log & lock capacity** (apply the earlier checklist): `LOGFILSIZ`, `LOGPRIMARY`, `LOGBUFSZ`, `LOCKLIST`, `MAXLOCKS`. Place logs on dedicated NVMe.
5. **Group commit behavior** — DB2 will batch log flushes; smaller transactions may still group. Measure commits/sec and ensure log device can sustain the throughput.
6. **Retry/backoff** — implement fast retry with randomized backoff on `SQL0911N` to handle transient waits. Keep retry window small to avoid pile-ups.
7. **Monitor during tests** — run load tests while watching `db2pd -locks`, `db2pd -logs`, I/O latency, and CPU.
8. **Partition / cluster if hot pages persist** — partitioning removes shared physical pages between threads and is a robust fix if reorganization is feasible.

---

### What to test now (quick A/B experiments)

1. **Baseline test**: 18 threads, batch=1,000, measure total time, commits/sec, `db2pd -locks`, log MB/s.
2. **Batch sweep**: test 500, 1,000, 2,000, 5,000. Plot deadlocks and total run time.
3. **Ordering test**: for batch=1,000, compare random key order vs sorted-by-PK.
4. **Index impact test**: run with non-critical secondary indexes dropped/recreated and compare.

---

### Short example calculation you can paste to scripts

* Per-thread target: **\~2,222 updates/sec**
* If batch=1,000 → each thread must finish a batch every **0.45 s** and do **≈667 batches** total.

---

### Self-critique (quick Gibson-style check)

* I assumed uniform distribution of records across threads and that each thread truly touches disjoint logical ranges. If your data is skewed (some threads get "hot" keys), the required per-thread rate becomes uneven and you must rebalance ranges.
* I also assumed DB2 groups commits and that your log/io path can handle the commit rate — measure WAL/log MB/s against the table I produced earlier to confirm.

---

### Takeaways (Heath & Heath style)

* Each of 18 threads must do **\~2,222 updates/sec** to finish 12M in 5 min.
* Start with **batch = 1,000–5,000** (1,000 is safest), giving **0.45–2.25 s** per batch per thread.
* Watch **commit rate** systemwide (40 commits/sec at 1k batch) and **log I/O** — these often limit throughput.
* If hot-page contention persists, use **ordering + partitioning** to eliminate it.

Want me to produce the exact test script (pseudo-SQL / shell) to run these experiments on DB2 (including commands to capture `db2pd -locks` and log stats)? I’ll include the metrics to collect and a sample chart layout.
