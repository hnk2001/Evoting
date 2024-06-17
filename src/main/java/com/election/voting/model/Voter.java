package com.election.voting.model;


import java.time.LocalDate;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.Lob;
import jakarta.persistence.ManyToOne;
import lombok.Data;

@Entity
@Data
public class Voter {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String firstName;
    private String middleName;
    private String lastName;
    private LocalDate dateOfBirth;
    private String gender;

    @Column(nullable = false, unique = true)
    private String contactNumber;

    @Column(name = "house_no/flat_no")
    private String houseNoFlatNo;
    @Column(name = "area/ward_no")
    private String areaOrWardNo;
    @Column(name = "city/village")
    private String cityOrVillage;
    private String taluka;
    private String pincode;
    private String district;
    private String state;
    private String country;

    @Column(nullable = false, unique = true)
    private String aadhaarNumber;
    @Column(nullable = false, unique = true)
    private String voterId;

    @Lob
    @Column(columnDefinition = "MEDIUMBLOB")
    private byte[] adhaarImage;

    @Lob //Indicate a large object field
    @Column(columnDefinition = "MEDIUMBLOB")
    private byte[] voterImage;

    @Lob
    @Column(columnDefinition = "MEDIUMBLOB")
    private byte[] faceImage;

    @ManyToOne
    @JoinColumn(name = "admin_id")
    private Admin admin;

    public Voter() {
    }
}