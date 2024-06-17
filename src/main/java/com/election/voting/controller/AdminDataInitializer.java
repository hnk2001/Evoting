package com.election.voting.controller;
import com.election.voting.model.Admin;
import com.election.voting.model.AdminRole;
import com.election.voting.repository.AdminRepository;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.sql.Timestamp;
import java.time.Instant;

@Component
public class AdminDataInitializer {

    @Autowired
    private AdminRepository adminRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @PostConstruct
    public void init() {
        // Check if the admin with username "cadmin" already exists
        Admin existingAdmin = adminRepository.findByUsername("cadmin");

        // If the admin does not exist, create it
        if (existingAdmin == null) {
            Admin admin = new Admin();
            admin.setUsername("cadmin");
            admin.setPassword(passwordEncoder.encode("cadmin"));
            admin.setMobile("9823456534");
            admin.setEmail("cadmin@gmail.com");
            admin.setFullName("Sushil Chandra");
            admin.setRole(AdminRole.CENTRAL);
            admin.setHouseNoFlatNo("123");
            admin.setCityOrVillage("NA");
            admin.setTaluka("NA");
            admin.setPincode("110002");
            admin.setDistrict("Delhi");
            admin.setState("NA");
            admin.setCountry("India");
            admin.setCreatedAt(Timestamp.from(Instant.now()));

            // Save the admin to the database
            adminRepository.save(admin);
        }
    }
}
