package com.election.voting.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.election.voting.model.Admin;

import java.util.List;
import java.util.Optional;


@Repository
public interface AdminRepository extends JpaRepository<Admin, Long>{
    
    Admin findByUsername(String username);

    Admin findByEmail(String email);

    Optional<Admin> findByMobile(String mobile);

    // ------------------- admin list according to admin id
    @Query("SELECT a FROM Admin a WHERE a.admin.id = :adminId")
    List<Admin> findAdminByAdminId(@Param("adminId") Long adminId);

    @Query("SELECT c FROM Admin c where c.username=:username")
    Optional<Admin> findByUsername1(String username);

    @Query("SELECT c FROM Admin c where c.email=:email")
    Optional<Admin> findByEmail1(String email);

}
