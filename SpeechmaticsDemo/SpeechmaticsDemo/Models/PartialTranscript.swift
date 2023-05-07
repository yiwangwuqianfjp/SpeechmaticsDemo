//
//  PartialTranscript.swift
//  SpeechmaticsDemo
//
//  Created by FanPengpeng on 2023/4/20.
//

import UIKit
/*
struct PartialTranscript: Codable {
    let startTime: Double
    let endTime: Double
    let transcript: String
    let results: [Result]
}

struct Result: Codable {
    let alternatives: [Alternative]
    let startTime: Double
    let endTime: Double
    let type: String
}

struct Alternative: Codable {
    let confidence: Double
    let content: String
}

func decodePartialTranscript(_ data: Data) -> PartialTranscript? {
    let decoder = JSONDecoder()
    do {
        let partialTranscript = try decoder.decode(PartialTranscript.self, from: data)
        return partialTranscript
    } catch {
        print("Error decoding partial transcript:", error)
        return nil
    }
}
*/


struct PartialTranscript: Codable {
    
    var metadata: MetaData?
    var results: [TranscriptResult]?
}

struct TranscriptResult: Codable {
    let alternatives: [Alternative]
    let start_time: Double
    let end_time: Double
    let type: String
}

struct MetaData: Codable {
    var start_time = 0.0
    var end_time = 0.0
    var transcript: String = ""
}

struct Alternative: Codable {
    let confidence: Double
    let content: String
    let language: String
}


func decodePartialTranscript(_ data: Data) -> PartialTranscript? {
    let decoder = JSONDecoder()
    do {
        let partialTranscript = try decoder.decode(PartialTranscript.self, from: data)
        return partialTranscript
    } catch {
        print("Error decoding partial transcript:", error)
        return nil
    }
}
