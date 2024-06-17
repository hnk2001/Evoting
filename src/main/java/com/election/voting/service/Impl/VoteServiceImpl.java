package com.election.voting.service.Impl;

import java.util.*;
import java.util.Map.Entry;

import com.election.voting.model.*;
import com.election.voting.repository.*;
import com.election.voting.service.CurrentElectionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.election.voting.service.VoteService;
import com.itextpdf.kernel.font.PdfFont;
import com.itextpdf.kernel.font.PdfFontFactory;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.Paragraph;


import java.io.FileNotFoundException;
import java.io.FileOutputStream;

import java.io.IOException;

@Service
public class VoteServiceImpl implements VoteService{
    
    @Autowired
    private VoteRepository voteRepository;

    @Autowired
    private VoterRepository voterRepository;

    @Autowired
    private CandidateRepository candidateRepository;

    @Autowired
    private ElectionRepository electionRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private CurrentElectionRepository currentElectionRepository;

    @Autowired
    private CurrentElectionService currentElectionService;

    @Override
    public void castVote(String voterId, String aadhaarNumber, Long candidateId, Long electionId){

        Candidate candidate = candidateRepository.findById(candidateId)
                .orElseThrow(() -> new NoSuchElementException("Candidate not found"));

        Election election = electionRepository.findById(electionId)
                .orElseThrow(() -> new NoSuchElementException("Election not found"));

        // set only voterId not Aadhaar Number
        if(voterId == null) {
            Voter voter = voterRepository.findByAadhaarNumber(aadhaarNumber);
            voterId = voter.getVoterId();
        }

        // check if the voter has already voted in election
        if (currentElectionRepository.existsByVoterAndElection(voterId, electionId)) {
            throw new IllegalStateException("Voter has already casted vote in this election");
        }

        // Record the vote
        Vote vote = new Vote();
        vote.setVoterId(passwordEncoder.encode(voterId));
        vote.setCandidate(candidate);
        vote.setElection(election);
        voteRepository.save(vote);

        currentElectionService.castVote(voterId,electionId);
    }

    @Override
    public Map<String, Long> getElectionResults(String electionname) throws IOException, FileNotFoundException {
        Optional<Election> election = electionRepository.findByName(electionname);
        String electionName="";
        if(election.isPresent()){
            electionName = election.get().getName();
        }
        // Retrieve all candidates for the election
        List<Candidate> candidates = candidateRepository.findByElectionName(electionName);

        // Retrieve election results
        List<Object[]> results = voteRepository.getElectionResultsByElectionName(electionname);

        // Initialize map to store vote counts for each candidate
        Map<String, Long> electionResults = new HashMap<>();

        // Initialize the vote count for all candidates to 0
        for (Candidate candidate : candidates) {
            electionResults.put(candidate.getName() + " (Party: " + candidate.getParty() + ")", 0L);
        }

        // Update vote counts based on actual results
        for (Object[] result : results) {
            Candidate candidate = (Candidate) result[0];
            Long voteCount = (Long) result[1];
            electionResults.put(candidate.getName() + " (Party: " + candidate.getParty() + ")", voteCount);
        }

        // Get user's home directory
        String userHome = System.getProperty("user.home");

        // Define the file name and path
        String fileName = "election_results.pdf";
        String filePath = userHome + "/Downloads/" + fileName;

        // Create a new PDF document
        PdfWriter writer = new PdfWriter(new FileOutputStream(filePath));
        PdfDocument pdfDocument = new PdfDocument(writer);
        Document document = new Document(pdfDocument);

        // Add title
        PdfFont font = PdfFontFactory.createFont("Helvetica");
        Paragraph title = new Paragraph("Election Results").setFont(font);
        document.add(title);

        // Add election name
        document.add(new Paragraph("Election Name: " + election.get().getName()));

        // Add results for all candidates
        for (Entry<String, Long> entry : electionResults.entrySet()) {
            Paragraph result = new Paragraph("Candidate: " + entry.getKey() + ", Votes: " + entry.getValue());
            document.add(result);
        }

        // Close the document
        document.close();

        return electionResults;
    }
}
