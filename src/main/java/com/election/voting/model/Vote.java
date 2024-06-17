package com.election.voting.model;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import lombok.Data;

@Entity
@Data
public class Vote {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @JoinColumn(name = "voter_id",nullable = false)
    private String voterId;

    @ManyToOne
    @JoinColumn(name = "candidate_id", nullable = false)
    private Candidate candidate;
    
    @ManyToOne
    @JoinColumn(name = "election_id", nullable = false)
    private Election election;

    public Vote(Long id, String voterId, Candidate candidate, Election election) {
        this.id = id;
        this.voterId = voterId;
        this.candidate = candidate;
        this.election = election;
    }

    public Vote() {
    }
}