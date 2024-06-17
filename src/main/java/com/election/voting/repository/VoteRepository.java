package com.election.voting.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import com.election.voting.model.Vote;
import org.springframework.data.repository.query.Param;

public interface VoteRepository extends JpaRepository<Vote, Long>{

    @Query("SELECT v.candidate, COUNT(v) FROM Vote v JOIN v.election e WHERE LOWER(e.name) = LOWER(:electionName) GROUP BY v.candidate")
    List<Object[]> getElectionResultsByElectionName(@Param("electionName") String electionName);

}
