package com.election.voting.model;

import java.time.LocalDateTime;
import com.fasterxml.jackson.annotation.JsonFormat;

import java.sql.Timestamp;
import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
public class Election {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private ElectionAssembly assembly;
    private String location;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss.SSSS")
    private LocalDateTime startTime;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss.SSSS")
    private LocalDateTime endTime;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    @ManyToOne
    @JoinColumn(name = "admin_id")
    private Admin admin;

    public Election(Long id, String name, ElectionAssembly assembly, String location, LocalDateTime startTime,
            LocalDateTime endTime, Timestamp createdAt, Timestamp updatedAt, Admin admin) {
        this.id = id;
        this.name = name;
        this.assembly = assembly;
        this.location = location;
        this.startTime = startTime;
        this.endTime = endTime;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.admin = admin;
    }

    public Election() {
    }

}