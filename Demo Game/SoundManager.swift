import AVFoundation

class SoundManager {
    static let instance = SoundManager()
    
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var flipSoundPlayer: AVAudioPlayer?
    private var winSoundPlayer: AVAudioPlayer?
    private var lostSoundPlayer: AVAudioPlayer?
    private var tieSoundPlayer: AVAudioPlayer?

    private init() {
        loadSounds()
    }

    private func loadSounds() {
        backgroundMusicPlayer = loadSound(named: "background_music", withExtension: "mp3")
        backgroundMusicPlayer?.numberOfLoops = -1
        backgroundMusicPlayer?.volume = 0.4

        flipSoundPlayer = loadSound(named: "card_flip", withExtension: "mp3")
        flipSoundPlayer?.volume = 1.5
        winSoundPlayer = loadSound(named: "winner_sound", withExtension: "mp3")
        winSoundPlayer?.volume = 0.9
        lostSoundPlayer = loadSound(named: "lost_sound", withExtension: "mp3")
        tieSoundPlayer = loadSound(named: "tie_sound", withExtension: "mp3")
    }

    private func loadSound(named name: String, withExtension ext: String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("Failed to load sound: \(name).\(ext)")
            return nil
        }
        return try? AVAudioPlayer(contentsOf: url)
    }

    func playBackgroundMusic() {
        if backgroundMusicPlayer?.isPlaying == false {
            backgroundMusicPlayer?.currentTime = 0
            backgroundMusicPlayer?.play()
        }
    }

    func pauseBackgroundMusic() {
        backgroundMusicPlayer?.pause()
    }

    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
        backgroundMusicPlayer?.currentTime = 0
    }

    func playFlipSound() {
        flipSoundPlayer?.currentTime = 0
        flipSoundPlayer?.play()
    }

    func playWinSound() {
        winSoundPlayer?.currentTime = 0
        winSoundPlayer?.play()
    }

    func playLostSound() {
        lostSoundPlayer?.currentTime = 0
        lostSoundPlayer?.play()
    }

    func playTieSound() {
        tieSoundPlayer?.currentTime = 0
        tieSoundPlayer?.play()
    }
    
    func pauseAllSounds() {
        backgroundMusicPlayer?.pause()
        winSoundPlayer?.pause()
        lostSoundPlayer?.pause()
        tieSoundPlayer?.pause()
        flipSoundPlayer?.pause()
    }
}
