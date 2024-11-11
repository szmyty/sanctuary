# Audio Processing Pipeline Overview

## High-Level Goals
This pipeline is designed for music producers to enhance audio tracks using AI-driven tools and modular architecture. It enables song enrichment through stems, metadata extraction, file conversions, and creative tools like biomimicry and artwork generation. The end product is a fully enriched project file for use in DAWs like Ableton.

---

## Pipeline Outline

### 1. User Input
- **Frontend**: React-based UI for submitting requests.
- **Backend**: Prompts AI tools (e.g., Suno AI) to generate the initial audio file.

---

### 2. Initial Data Storage
- **Storage**: Files are stored in MinIO (local-first) or S3 (scalable).
- **Metadata**: Tracks file status (e.g., unprocessed, processing, processed).

---

### 3. Processing Steps
#### 3.1. Audio File Conversion
- Convert input audio into multiple formats (`.wav`, `.mp3`, `.ogg`, etc.).

#### 3.2. Stem Splitting
- Split the audio track into stems (e.g., vocals, drums, bass) using AI.

#### 3.3. Pitch Shifting
- Generate 24 pitch-shifted versions of each stem (-12 to +12 semitones).

#### 3.4. MIDI Extraction
- Extract MIDI representations for each stem.

#### 3.5. Key and BPM Detection
- Detect the key and BPM of the overall track and individual stems.

#### 3.6. Auto-Sample Generation
- Chop stems into smaller samples for a sample library.
- Filter out low-quality or silent samples.

#### 3.7. Lyrics Detection (Optional)
- Extract lyrics from vocal stems and save as `.txt` files.

#### 3.8. Mood Classification
- Analyze the track for mood and map it to emotions.
- Use this data to enhance other tools (e.g., artwork, visualizations).

#### 3.9. Artwork Generation
- Generate album artwork using AI tools (e.g., DALL·E, Stable Diffusion).
- Create multiple variations based on metadata and mood classification.

#### 3.10. Biomimicry Waveform Generation
- Generate a **biomimetic waveform** to balance the track:
  - Analyze harmonic data from the song.
  - Create a tuning waveform or binaural beat as a subtle background layer.

---

### 4. Enriched Output
- Combine processed elements into an enriched project file, including:
  - Processed stems and samples.
  - MIDI files.
  - Metadata (key, BPM, mood).
  - Artwork.
  - Optional biomimetic waveform.

---

## Orchestration and Fault Tolerance
- **Kestra**:
  - Manages pipeline tasks and monitors processing status.
- **Fault Tolerance**:
  - Track file states using MinIO metadata or a database.
  - Enable recovery of interrupted processes.

---

## Future Enhancements
1. **Harmonic Analysis**:
   - Generate chord progressions or harmonic maps from stems.

2. **Spectral Analysis**:
   - Create spectrograms for visual analysis of audio tracks.

3. **Audio Effects Processing**:
   - Apply effects like reverb and compression for alternate stem versions.

4. **Genre Classification**:
   - Classify the genre of tracks and add tags to metadata.

5. **Beat Segmentation**:
   - Divide tracks into loopable segments based on beats or measures.

6. **Dynamic Visualization**:
   - Create 3D visualizations of the pipeline or song data (e.g., Three.js).

7. **Text-to-Video Music Videos**:
   - Generate music videos using text-to-video technologies and extracted metadata.

---

## Proposed Directory Structure
```plaintext
/project_root/
  /original/
    - new_song.wav
  /converted/
    /mp3/
    /ogg/
    ...
  /stems/
    /vocals/
      - vocals.wav
      - vocals_midi.mid
      /pitch_shifted/
        - vocals_pitch_-12.wav
        - vocals_pitch_+12.wav
      /samples/
        - vocals_sample_01.wav
        - vocals_sample_02.wav
    /drums/
      ...
  /metadata/
    - song_metadata.json
    - lyrics.txt
  /final_output/
    - enriched_ableton_project.zip