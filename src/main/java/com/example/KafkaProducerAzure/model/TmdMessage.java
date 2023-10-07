package com.example.KafkaProducerAzure.model;

import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlProperty;
import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlRootElement;

@JacksonXmlRootElement(localName = "Message")
public class TmdMessage {

    @JacksonXmlProperty(localName = "Module")
    private String module;

    @JacksonXmlProperty(localName = "Qty")
    private int qty;

    @JacksonXmlProperty(localName = "Id")
    private int id;

    public String getModule() {
        return module;
    }

    public void setModule(String module) {
        this.module = module;
    }

    public int getQty() {
        return qty;
    }

    public void setQty(int qty) {
        this.qty = qty;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    @Override
    public String toString() {
        return "TmdMessage{" +
                "module='" + module + '\'' +
                ", qty=" + qty +
                ", id=" + id +
                '}';
    }
}
