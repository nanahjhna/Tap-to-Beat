import sys
import json

try:
    import librosa
except ImportError:
    print("Error: librosa is not installed.")
    print("Install with: pip install librosa")
    sys.exit(1)

if len(sys.argv) != 3:
    print(f"Usage: {sys.argv[0]} <input.mp3> <output.json>")
    sys.exit(1)

audio_path = sys.argv[1]
output_path = sys.argv[2]

y, sr = librosa.load(audio_path, sr=22050)
tempo, beats = librosa.beat.beat_track(y=y, sr=sr)
beat_times = librosa.frames_to_time(beats, sr=sr)
beat_ms = [int(t * 1000) for t in beat_times]

with open(output_path, 'w') as f:
    json.dump(beat_ms, f)

print(f"Detected {len(beat_ms)} beats. Output: {output_path}")
