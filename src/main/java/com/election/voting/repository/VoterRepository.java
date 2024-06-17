package com.election.voting.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.election.voting.model.Voter;

@Repository
public interface VoterRepository extends JpaRepository<Voter, Long>{
    @Query("SELECT v FROM Voter v WHERE v.aadhaarNumber = ?1")
    Voter findByAadhaarNumber(String aadhaarNumber);
    
    @Query("SELECT v FROM Voter v WHERE v.voterId = ?1")
    Voter findByVoterId(String voterId);

    @Query("SELECT v FROM Voter v WHERE v.district = :district")
    List<Voter> findVoterByDistrict(String district);

    @Query("SELECT v FROM Voter v WHERE v.taluka = :location")
    List<Voter> findVoterByTaluka(String location);

    @Query("SELECT v FROM Voter v WHERE v.cityOrVillage = :cityOrVillage")
    List<Voter> findVotersByCityOrVillage(String cityOrVillage);

    @Query("SELECT v FROM Voter v WHERE v.voterId = ?1 OR v.aadhaarNumber = ?2")
    Optional<Voter> findByVoterIdOrAadhaarNumber(String voterId, String aadhaarNumber);

    @Query("SELECT COUNT(v) FROM Voter v WHERE v.district = :district")
    long countVotersByDistrict(@Param("district") String district);

    @Query("SELECT COUNT(v) FROM Voter v WHERE v.taluka = :district")
    long countVotersByTaluka(@Param("district") String district);

    @Query("SELECT COUNT(v) FROM Voter v WHERE v.cityOrVillage = :district")
    long countVotersByCityOrVillage(@Param("district") String district);

    @Query("SELECT v FROM Voter v WHERE v.contactNumber = :contactNumber")
    Optional<Voter> findByMobileNumber(String contactNumber);
}
