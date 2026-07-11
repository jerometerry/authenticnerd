---
title: "Ego vs. Authenticity"
pubDate: 2026-07-11
subtitle: "Why I spent a month building a Linux driver with AI, and chose not to upstream it."
description: "A one-month deep dive into V4L2, LibUSB, and C++ led to a working driver, but sparked a deeper realization about AI, ego, and true engineering mastery."
author: "Jerome Terry"
image:
  url: "../assets/pi-borescope-streamer.png"
  alt: "Screen capture showing several browser tabs viewing the live stream from my borescope"
tags:
  [
    "ai",
    "useeplus-protocol",
    "programming",
    "c++",
    "v4l2",
    "linux driver",
    "systems-thinking",
    "engineering",
  ]
---

## A Simple Problem and a Cheap Camera

I ran into rotating assembly clearance issues during my [NifeliZ L6 Model Engine](/posts/nifeliz-l6) build.
To get a good look at the clearance issues, I ordered the [Kinpthy Endoscope Camera](https://www.amazon.ca/dp/B0C9JR3N4W)
from Amazon for $50 CAD. The endoscope worked pretty well, for the price. Below is a picture of the
endoscope along with a sample video to see the quality.

---

![Kinpthy Endoscope Camera](../assets/borescope.png)

---

<div class="aspect-9/16 w-full max-w-sm mx-auto mb-8 overflow-hidden rounded-xl shadow-md bg-black">
  <iframe
    class="w-full h-full"
    src="https://www.youtube-nocookie.com/embed/9t56tPym-fY"
    title="NifeliZ L6 Engine Short"
    frameborder="0"
    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
    referrerpolicy="strict-origin-when-cross-origin"
    allowfullscreen>
  </iframe>
</div>

---

## Curiosity Killed the Cat

I got curious about whether the endoscope would work as a webcam on my Mac. I tried plugging the
endoscope into my Mac and my Raspberry Pi. I tried using the borescope as a webcam, but neither my
Mac nor my Raspberry Pi could stream video from it.

Then I googled how to get this borescope working on a Mac or Raspberry Pi. Video 4 Linux seemed like
the most viable option; however, I could not get Video 4 Linux to work with the camera either.

Then I googled how to make the borescope work with Video 4 Linux. That led me to the GitHub projects
[Endoscope Camera](https://github.com/jmz3/EndoscopeCamera) by [jmz3](https://github.com/jmz3) and
[Geek szitman supercamera](https://github.com/hbens/geek-szitman-supercamera) by
[hbens](https://github.com/hbens). The "Endoscope Camera" project is a video streamer for the
endoscope, based on the work of hbens in the "Geek szitman supercamera" project. The
"Geek szitman supercamera" contains a proof of concept OpenCV application that decodes the custom
Useeplus protocol stream from the endoscope using LibUSB.

## Prototyping and Domain-Driven Design

I wanted to see if I could get a prototype working on my Raspberry Pi. I cloned both repos, then
started building my own project based on
[geek-szitman-supercamera/supercamera_poc.cpp](https://github.com/hbens/geek-szitman-supercamera/blob/master/supercamera_poc.cpp).

Setting up the build tools and installing the dependencies took a bit of doing, but I managed to get
my own working prototype. Then my software refactoring instincts kicked in, and I started
reworking the code.

That refactoring exercise evolved into a highly focused, one-month sprint. While hbens had done the
foundational work of reverse-engineering the base protocol, I dove into expanding it. By
disassembling the camera's Android JNI libraries, I figured out how to command the camera into
higher, undocumented resolutions (like 1280x960) and handle the hardware's tendency to pad its 4KB
memory pages with stale, uninitialized data.

Instead of just porting the code, I applied Domain-Driven Design (DDD) concepts to model the actual
physical and digital boundaries of the system. I enforced strict naming conventions, explicitly
requiring layer prefixes—like `usb_frm` at the link layer versus `video_frm_frag` at the
presentation layer—to avoid ambiguity and make the codebase highly accessible to a hobbyist reading
the code on a Raspberry Pi. I engineered the system for performance, architecting a zero-allocation
steady-state pipeline, implementing an LMAX Disruptor lockless ring buffer, and utilizing custom
`bpftrace` scripts to hunt down rogue memory allocations and pinpoint URB completion bottlenecks.

But while I acted as the Principal Architect, I used Google Gemini Pro as my junior developer for
the grunt work. I relied heavily on AI to translate my logic into the specific Video4Linux (V4L2)
and VideoBuffer2 (VB2) kernel APIs. I used it to iterate rapidly through Zig cross-compilation
errors, automate the Makefiles, and polish the syntax until `checkpatch.pl`, `clang-tidy`, `IWYU`,
and `cppcheck` ran perfectly clean, and all `v4l2-compliance` tests passed.

I published this work under an MIT license on GitHub:
[github.com/jerometerry/useeplus](https://github.com/jerometerry/useeplus) repository.

## Patch Anxiety

The AI kept pushing me to create the official patch, telling me it was ready for review. I have to
disagree, Gemini.

I've never done any Linux Kernel development before, so building a V4L2 driver was a steep learning
curve. I relied on AI substantially to navigate the specifics of the kernel macros and subsystems.
Because I leaned on AI to bridge my specific knowledge gap in V4L2, I don't feel comfortable that I
know the kernel-side API deeply enough to submit this driver as an official patch.

I considered creating a patch, but decided against it. I don't want to take on the responsibility
of maintaining an official Linux driver. Working with long-time Linux Kernel developers who have to
thoroughly review my patch made me feel uncomfortable after having done a V4L2 crash course in just
one month. I blindly accepted some of the AI's V4L2 recommendations just to appease the
`v4l2-compliance` tools, but passing tests isn't the same as understanding the kernel-level memory
management implications. I would need to be able to answer reviewers' questions with confidence
before I ever consider putting forward a patch, and I don't want to rely on AI to answer them for me.

The code might be ready, but I'm not. The thought of putting this work forward for review made me
very nervous and anxious. At first, I thought it was my insecurities of being judged by Linux kernel
developers for how crappy my code was. That was just the story I was telling myself.

What I believe now is that my body was telling me I wasn't ready, that this kernel-level translation
was mostly AI's doing, and I can't stand behind it because I don't know it well enough at a deep,
fundamental level. I was letting my ego pump itself up for having pushed through a one-month sprint
to build a highly performant prototype, while getting carried away thinking that four weeks of API
exposure somehow made me a kernel expert.

I was simultaneously insecure about my work and overconfident in my expertise. I was envisioning the
Linux Maintainers as overly picky, brutal reviewers as a way of avoiding what my body was trying to
tell me. I used AI to build a prototype. It was fun. The architecture is mine, and it is done to the
best of my abilities. Yet that isn't enough to justify a patch. If I had put forward a patch, I
would have been a nervous wreck, but I would have been misattributing my nervousness as a fear of
the reviewers' criticism, instead of to my inner struggle to try and prove myself and get validation
by having code merged into the Linux Kernel.

## Authenticity

It would not be authentic for me to put my work forward with my current level of knowledge. The
code may or may not be up to the standards of the Linux Kernel. That isn't the point.

While I can speak confidently about the overarching C++ architecture, the zero-allocation pipeline,
and how my domain-driven design expands on hbens's protocol decoding, I cannot definitively defend
the nuanced design choices within the V4L2 and VB2 implementations.

If a maintainer asked _why_ I used a full memory barrier (`smp_mb__after_atomic()`) in the teardown
sequence instead of a simple spinlock, or why I set the `URB_NO_TRANSFER_DMA_MAP` flag for the USB
request block allocations, my honest answer would be "because the AI told me to." If they asked why
my driver advertises `V4L2_CAP_TIMEPERFRAME` but hardcodes the `VIDIOC_G_PARM` ioctl response to a
static 30 FPS just to make the `v4l2-compliance` test turn green, my answer would be "to pass the
test, not to bind the hardware clock." That is not an acceptable answer on the Linux Kernel Mailing
List.

By keeping it on GitHub under an MIT license rather than forcing a kernel patch, I'm hoping to pass
the baton. It’s out there for someone who does have the deep foundational expertise—and the
desire—to take this architectural prototype and publish an official Video4Linux2 driver for
Useeplus cameras.
