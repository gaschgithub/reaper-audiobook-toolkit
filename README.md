# reaper-audiobook-toolkit

⚠️ **Work in Progress**  
This repository documents an evolving set of REAPER/Lua scripts developed in professional audiobook editing practice. The codebase is **not frozen** and may change as editorial strategies evolve.

---

## Overview

This repository contains a small toolkit of Lua scripts designed to support **long-form spoken-word and audiobook editing workflows** inside REAPER.

Rather than aiming for full automation or commercial plugin development, the scripts formalize **recurrent editorial decisions**—such as pacing adjustments and pickup preparation—into transparent procedures that can be repeatedly applied across large projects.

The toolkit emerges from **practice-based research**: scripts are developed, tested, and refined directly within real audiobook production contexts, responding to platform constraints (e.g. pacing guidelines) and perceptual considerations (e.g. naturalness of speech timing).

---

## Scope

- **Practice-driven development**  
  Scripts encode workflows that have proven effective in real audiobook production.

- **DAW-native integration**  
  All functionality is implemented using REAPER’s native Lua scripting API, without external dependencies.

This repository does **not** attempt to:
- perform automatic speech recognition or alignment,
- replace human editorial decisions,
- function as a polished or stable software package.

---

## Included Scripts (current)

- **`regionnamer.lua`**  
  Assists in the preparation of pickup sessions by automatically naming regions based on nearby error markers, following audiobook post-production conventions.

- **`move_random_sentence.lua`**  
  Repaces short silence gaps (≈800–900 ms) between adjacent narration items using controlled randomness to preserve natural speech flow.

- **`move_random_paragraph.lua`**  
  Repaces longer paragraph-level gaps (≈1240–1380 ms).

---

## Project Status

**Status:** Work in Progress / Ongoing Practice-Based Development

This repository is not a finalized research artifact.  
It documents scripts that are actively used, tested, and modified in professional audiobook editing workflows.

Changes may include:
- parameter tuning (e.g. pacing ranges),
- refactoring for clarity and robustness,
- addition or removal of scripts,
- reorganization of the folder structure.

If a stable methodological state is reached, a tagged snapshot may be created for reference.

---

## Intended Audience

This repository is intended for:
- researchers and students interested in **practice-based tool development** for audio production,
- audiobook editors working with REAPER and Lua scripting,
- reviewers evaluating research portfolios

