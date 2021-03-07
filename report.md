---
title: "End Term Project Report: otoDecks"
author: Mohammad Hussain Nagaria
date: 5 March, 2021
---


# Introduction

As I was coding along with the lectures and completing the worksheets, by the end of the course, I already had the [basic functionality](#r1-basic-functionality) in place.

I planned to start with the [playlist component](#r3-the-music-library), since I found it interesting and also very essential for such an application. Once, I was done with the playlist component, I moved to give the GUI an [overhaul](#r4-the-new-gui-layout). At the very last, I worked on the [custom deck control](#r2-the-custom-deck-control) and added some finishing touches. I have used a variety of different things available in the **JUCE Library** and used the JUCE *documentation*[^1] for learning about different classes and methods available on those classes.

[^1]: JUCE Class Reference, https://docs.juce.com/master/index.html

Detailed information on the achievements of different requirements makes the rest of this report. I have attached **screenshots** and **code snippets** at various places to make things clearer.


# Requirements

## R1: Basic Functionality


## R2: The Custom Deck Control


## R3: The Music Library

The Music Library Component has been *encapsulated* into a component called: `MusicLibrary`. It takes 3 constructor arguments: pointers to the 2 `DJAudioPlayer`s and pointer to the `DeckPanel` component. This component is **resizable**, so the user can drag along the top edge to change its height. The resizing was made possible using the `ResizableBorderComponent` inside the `DeckPanel` and some bounds setting in the `resized()` method of the main component:

```cpp
deckPanel.setBounds(
    deckPanel.getX(), 
    deckPanel.getY(), 
    getWidth(), 
    deckPanel.getHeight()
);

musicPanel.setBounds(
    0, 
    deckPanel.getHeight(), 
    getWidth(), 
    getHeight() - deckPanel.getHeight()
);
```
`musicPanel` is the name of the instance of MusicLibrary created in the MainComponent Class.

The first problem at hand was to add some persistent storage. While browsing through the JUCE documentation, I came across `juce::PropertiesFile` class. This class can be used to maintain a file for application data. The music library creates a pointer to a `PropertiesFile` and sets it up in the constructor via a method called `loadPlaylist`:

```cpp
void MusicLibrary::loadPlaylist() {

    // Configure options for properties file
    juce::PropertiesFile::Options playlistFileOptions;
    playlistFileOptions.applicationName = "music";
    playlistFileOptions.filenameSuffix = ".playlist";
    playlistFileOptions.folderName = "userMusicData";
    // ... other configuration omitted here

    // Create Property File object
    playlistFile = new juce::PropertiesFile(playlistFileOptions);

    // Load playlist
    int numSongs = playlistFile->getAllProperties().size();

    // Resize the vector to required size
    songs.resize(numSongs, juce::String());

    // Get all StringPairs from properties file
    juce::StringPairArray songArray = playlistFile->getAllProperties();

    // Fill the vector with song file paths
    // ...
}
```

I have **used this file to store paths to song/track** files. The content of the file is *loaded into the memory* (in a vector of `juce::String`s called `songs`, which is a private member of the MusicLibrary class) at the end of the method given above. Hence, whenever the application is started, previously *saved playlist* is loaded into the memory and displayed via the `TableListBox` component. (R3E)

## R4: The New GUI Layout


# Conclusion
