package com.example.KafkaProducerAzure.service;

import com.example.KafkaProducerAzure.model.TmdMessage;
import com.fasterxml.jackson.dataformat.xml.XmlMapper;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;
import com.fasterxml.jackson.core.type.TypeReference;



import java.io.IOException;
import java.io.InputStream;
import java.util.List;

@Service
public class KafkaProducerService {
    @Value("${kafka.topic.name}")
    private String topicName;

    @Autowired
    private KafkaTemplate<String, String> kafkaTemplate;


    private final XmlMapper xmlMapper;

    public KafkaProducerService() {
        this.xmlMapper = new XmlMapper();
    }

    @PostConstruct
    public void begin() {
        publishFileMessages();
    }

    public void publishFileMessages() {
        try (InputStream inputStream = getClass().getResourceAsStream("/data.xml")) {
            List<TmdMessage> messages = xmlMapper.readValue(inputStream, new TypeReference<>() {});
            for (TmdMessage message : messages) {
                String messageXml = xmlMapper.writeValueAsString(message);
                kafkaTemplate.send(topicName, messageXml);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

}
