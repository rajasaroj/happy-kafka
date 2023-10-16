package com.example.KafkaProducerAzure.service;

import com.example.KafkaProducerAzure.config.KafkaConfig;
import com.example.KafkaProducerAzure.model.TmdMessage;
import com.fasterxml.jackson.dataformat.xml.XmlMapper;
import jakarta.annotation.PostConstruct;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.core.ProducerFactory;
import org.springframework.stereotype.Service;
import com.fasterxml.jackson.core.type.TypeReference;



import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.Map;

@Service
public class KafkaProducerService {

    private static final Logger logger =  LoggerFactory.getLogger(KafkaProducerService.class);
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
        showKafkaTemplateProperties();
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

    public void showKafkaTemplateProperties() {
        ProducerFactory<String, String> producerFactory = kafkaTemplate.getProducerFactory();

        // Access producer properties
        Map<String, Object> producerConfig = producerFactory.getConfigurationProperties();
        String bootstrapServers = (String) producerConfig.get(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG);
        String acks = (String) producerConfig.get(ProducerConfig.ACKS_CONFIG);

        // Log or use the properties as needed
        logger.info("Bootstrap Servers: " + bootstrapServers);
        logger.info("Acknowledgment Mode: " + acks);
    }

}
