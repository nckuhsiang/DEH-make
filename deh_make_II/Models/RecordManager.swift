//
//  RecordManager.swift
//  DEH-Make-II
//
//  Created by Ray Chen on 2017/10/25.
//  Copyright © 2017年 Ray Chen. All rights reserved.
//

import Foundation
import AVFoundation

class RecordManager {
    
    var recorder: AVAudioRecorder?
    var player: AVAudioPlayer?
    
    func beginRecord(_ path: String) {  //開始錄音
        let session = AVAudioSession.sharedInstance()
        
        // 設置 session 類型
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let err{
            print("類型設置失敗:\(err.localizedDescription)")
        }
        
        // 設置 session 動作
        do {
            try session.setActive(true)
        } catch let err {
            print("初始化設定失敗:\(err.localizedDescription)")
        }
        
        // 錄音設置
        let recordSetting: [String: Any] = [
            AVFormatIDKey:Int(kAudioFormatMPEG4AAC),                                // 音頻格式
            AVSampleRateKey: NSNumber(value: 16000),                                // 採樣率
            AVLinearPCMBitDepthKey: NSNumber(value: 16),                            // 采样位数
            AVNumberOfChannelsKey: NSNumber(value: 1),                              // 通道数
            AVEncoderAudioQualityKey: NSNumber(value: AVAudioQuality.min.rawValue), // 錄音質量
        ];
        
        // 開始錄音
        do {
            let url = URL(fileURLWithPath: path)
            recorder = try AVAudioRecorder(url: url, settings: recordSetting)
            recorder!.prepareToRecord()
            recorder!.record(forDuration: 150)
            print("開始錄音")
        } catch let err {
            print("錄音失敗:\(err.localizedDescription)")
        }
    }
    
    //结束录音
    func stopRecord(_ path: String) {
        if let recorder = self.recorder {
            if recorder.isRecording {
                print("正在錄音，馬上结束它，文件保存到了：\(path)")
            }else {
                print("没有錄音，但是依然结束它")
            }
            recorder.stop()
            self.recorder = nil
        }else {
            print("没有初始化")
        }
    }
    
    
    //播放
    func play(_ path: String) {
        do {
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            print("歌曲長度：\(player!.duration)")
            player!.play()
        } catch let err {
            print("播放失敗:\(err.localizedDescription)")
        }
    }
    
    func stopPlay(_ path: String){
        do {
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            player!.stop()
        } catch let err {
            print("停止問題：\(err.localizedDescription)")
        }
    }
}

