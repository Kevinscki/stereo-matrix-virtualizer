/*
 * Stereo Matrix Virtualizer active decoder stream adapter.
 *
 * Copyright (C) 2026 Kelvin Rutatina
 * SPDX-License-Identifier: GPL-2.0-only
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2.
 */

#include "freesurround_adapter.h"

#include <cerrno>
#include <cstddef>
#include <cstdint>
#include <cstdio>
#include <unistd.h>
#include <vector>

namespace {
constexpr int kHostFrames = 256;
constexpr unsigned kAnalysisFrames = 1024;
constexpr unsigned kInputChannels = 2;
constexpr unsigned kOutputChannels = 8;

bool read_block(float* destination, std::size_t bytes, std::size_t& received) {
    received = 0;
    auto* output = reinterpret_cast<unsigned char*>(destination);
    while (received < bytes) {
        const ssize_t count = ::read(STDIN_FILENO, output + received, bytes - received);
        if (count > 0) {
            received += static_cast<std::size_t>(count);
            continue;
        }
        if (count == 0) return received != 0;
        if (errno == EINTR) continue;
        std::perror("stereo-active-decoder: read");
        return false;
    }
    return true;
}

bool write_all(const float* source, std::size_t bytes) {
    const auto* input = reinterpret_cast<const unsigned char*>(source);
    std::size_t written = 0;
    while (written < bytes) {
        const ssize_t count = ::write(STDOUT_FILENO, input + written, bytes - written);
        if (count > 0) {
            written += static_cast<std::size_t>(count);
            continue;
        }
        if (count < 0 && errno == EINTR) continue;
        if (count < 0 && errno == EPIPE) return false;
        std::perror("stereo-active-decoder: write");
        return false;
    }
    return true;
}
}  // namespace

int main() {
    FreeSurroundAdapter decoder(kHostFrames, cs_7point1, kAnalysisFrames);
    if (decoder.numChannels() != kOutputChannels) {
        std::fprintf(stderr, "stereo-active-decoder: expected 8 output channels\n");
        return 1;
    }

    decoder.setSampleRate(48000.0);
    decoder.setCenterImage(1.0f);
    decoder.setFrontSeparation(1.0f);
    decoder.setRearSeparation(1.0f);
    decoder.setCircularWrap(90.0f);
    decoder.setShift(0.0f);
    decoder.setDepth(1.0f);
    decoder.setFocus(0.0f);
    decoder.setBassRedirection(false);
    decoder.setRearCoherence(0.0f);

    std::vector<float> input(kHostFrames * kInputChannels, 0.0f);
    std::vector<float> left(kHostFrames, 0.0f);
    std::vector<float> right(kHostFrames, 0.0f);
    std::vector<std::vector<float>> channels(
        kOutputChannels, std::vector<float>(kHostFrames, 0.0f));
    std::vector<float*> channelPointers(kOutputChannels, nullptr);
    std::vector<float> output(kHostFrames * kOutputChannels, 0.0f);
    for (unsigned channel = 0; channel < kOutputChannels; ++channel)
        channelPointers[channel] = channels[channel].data();

    const std::size_t inputBytes = input.size() * sizeof(float);
    while (true) {
        std::size_t received = 0;
        if (!read_block(input.data(), inputBytes, received)) break;
        if (received % (kInputChannels * sizeof(float)) != 0) {
            std::fprintf(stderr, "stereo-active-decoder: truncated input frame\n");
            return 1;
        }

        const int frames = static_cast<int>(received / (kInputChannels * sizeof(float)));
        for (int frame = 0; frame < frames; ++frame) {
            left[frame] = input[frame * 2];
            right[frame] = input[frame * 2 + 1];
        }
        decoder.process(left.data(), right.data(), frames, channelPointers.data());
        for (int frame = 0; frame < frames; ++frame)
            for (unsigned channel = 0; channel < kOutputChannels; ++channel)
                output[static_cast<std::size_t>(frame) * kOutputChannels + channel] =
                    channels[channel][frame];

        if (!write_all(output.data(), static_cast<std::size_t>(frames) *
                                      kOutputChannels * sizeof(float)))
            break;
        if (received != inputBytes) break;
    }
    return 0;
}
