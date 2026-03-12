# One Chord Requiem for virtual piano

Notes for an 8-minute talk

Source post:  
https://scsynth.org/t/one-chord-requiem-for-virtual-piano/7747

Source code:  
https://sccode.org/1-5hc

## Introduction

The piece repeats one randomly generated 24-note MIDI chord while changing which notes are emphasized.
It uses a sine-based lookup table (`lut`) to reshape velocity, so the harmony stays mostly the same but the internal focus keeps moving.

## Structure Outline

- Every 127 cycles: halve the lookup-table period and reverse the scan direction
- Every 508 cycles: widen the strum, shorten the gap between chords, and reshuffle note order
- After cycle 890: enter a more unstable finale section
- At cycle 915: stop, use sustain pedal for the ending, then release

## Aesthetic Critique

The piece is not mainly about changing harmony, but about shifting attention inside one harmony.
The loudness, timing, and order of the notes keep changing, so the sound keeps moving.

## Code Critique

### Important notes

#### Random chord generation

Lines `39-43`

- The code selects 24 different MIDI pitches between 20 and 100, then sorts them from low to high.
- `bins = Set[]` is used to make sure pitches are unique.
- `while ({bins.size < no_of_bins})` keeps running until the set contains 24 notes.
- `20.rrand(100)` generates one random MIDI pitch each time.
- `bins.asList.sort` turns the set into an ordered list, which becomes the fixed chord material used later.

#### Lookup table logic

Lines `31-37`, `50-53`, `85-89`

- `table` is a function that builds a sine-shaped velocity lookup table.
- `127.collect` generates 127 velocity values.
- `sin(2pi*time/period + phase)` creates points on a sine wave.
- `.linlin(-1, 1, rangemin, rangemax)` maps those values into a MIDI velocity range.
- Whenever `idx.mod(127) == 0`, the code rebuilds `lut` and reverses `direction`.
- During playback, each note reads a different velocity value from `lut` using `finalidx`.
- So the harmony stays mostly the same, but the internal emphasis keeps shifting.

### Code landmarks from the source

- Lines `13-55`: setup, MIDI initialization, lookup-table function, random pitch selection
- Lines `57-114`: main performance loop
- Lines `116-125`: pedal-based ending

### Part 1

Lines `13-38`, `49-55`

Variable setup
- `no_of_bins`: number of notes in the fixed pitch collection
- `bins`: the unique MIDI pitch set that forms the "one chord"
- `table`: function that builds the sine-shaped velocity lookup table
- `lut`: the current lookup table
- `period`: initial lookup-table period; later it shrinks to increase activity
- `rangemin` / `rangemax`: MIDI velocity lower and upper limits
- `strum`: the first section update pushes it to 0, then keeps increasing it
- `delay_between_chords`: wait time between chord repetitions
- `direction`: controls whether the table scan moves forward or backward
- `idx`: long-form section counter
- `ampmod`: global fade factor used in the later section


### Part 2

Lines `41-47`, `62-65`, `100-105`

Lookup table mechanism
- It generates 127 sine-based velocity values and maps them into the MIDI velocity range.
- Each note reads a different position from the lookup table.
- The harmony itself stays mostly the same.
- The main change happens in the internal balance of the chord.

```supercollider
finalidx = (wrappedidx + (bin * direction)).wrap(0, 126)
```

### Part 3

Lines `18-27`, `57-114`

Section changes
- Every 127 cycles: speed up the movement of internal emphasis and reverse the scan direction
- Every 508 cycles: widen the strum and shorten the gap between chords
- Before the finale: force a wider strum and reshuffle the note order
- In the finale: disturb timing, direction, and amplitude while the whole texture fades
- At `idx == 915`: stop the whole process

### Part 4

Lines `29-35`, `116-125`

Ending and cleanup
- If the user stops the code manually, `CmdPeriod.doOnce` turns off all notes to avoid stuck MIDI notes.
- The ending uses sustain pedal first, then releases all notes so the virtual piano can decay naturally.
