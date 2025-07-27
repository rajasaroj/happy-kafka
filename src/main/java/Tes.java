import java.util.ArrayList;
import java.util.List;

public class Tes {
    public static void main(String[] args) {
        int[] weight = {10, 20, 30, 40};
        System.out.println(misDis("R|A|J|A", "R|I|J|A", weight));
    }

    public static int misDis(String s, String t, int[] weight) {
        String[] sArr = s.split("\\|");
        String[] tArr = t.split("\\|");
        int val =0;
        List<Integer> lst = new ArrayList<>();

        for (int i = 0; i < sArr.length; i++) {
            if (!sArr[i].equals(tArr[i])) {
                lst.add(i);
                val = val + weight[i];
            }
        }



        return val;
    }


    public static int minDistance(String s, String t) {
        int m=s.length();
        int n=t.length();
        int dp[][]=new int[m+1][n+1];
        for(int i=0;i<=m;i++) dp[i][0]=i;
        for(int i=0;i<=n;i++) dp[0][i]=i;

        for(int i=1;i<=m;i++){
            for(int j=1;j<=n;j++){

                if(s.charAt(i-1)==t.charAt(j-1)) dp[i][j]=dp[i-1][j-1];
                else dp[i][j]=1+Math.min(dp[i-1][j-1],Math.min(dp[i-1][j],dp[i][j-1]));

            }
        }
        return dp[m][n];
    }
}
