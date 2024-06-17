package com.election.voting.repository;

import com.election.voting.model.CurrentElection;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface CurrentElectionRepository extends JpaRepository<CurrentElection, Long> {
    // checking one vote cast vote only one time
    @Query("SELECT CASE WHEN COUNT(e) > 0 THEN true ELSE false END FROM CurrentElection e WHERE e.voterId = :voterId AND e.electionId = :electionId")
    boolean existsByVoterAndElection(String voterId, long electionId);

    // number of voters for particular electionId
    @Query("SELECT COUNT(c) FROM CurrentElection c WHERE c.electionId = :electionId")
    long countVotersByElectionId(Long electionId);
}
