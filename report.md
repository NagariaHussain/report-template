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

This application contains all the basic functionality shown in the course lectures (I have been coding along, :)):

1. The user can load audio files into any of the two Decks. This can either be done by **clicking the load button** in the Deck or by **dragging and dropping** a music file onto the deck component. (**R1A**)

2. Music files can be loaded and played simultaneously in the two decks. (**R1B**)

3. The volumes of each of the tracks can be controlled independently, using the volume slider in the deck. (**R1C**)

4. The speeds of each of the tracks playing the two decks can also be controlled independently, using the speed slider in the deck. (**R1D**)

In the lectures, we are shown how to change the play head using a slider. I went one step ahead to change this behavior into something much **more natural**. I have used some mouse click listeners and some geometry to enable the user to **drag the play head rectangle** to change the play head position. This seemed a bit tricky to implement at first, but gave a lot of satisfaction once it was done. The screenshot below shows a user dragging the playhead indicator to a new position (**Extra**):

![Screenshot of play head being dragged to a new position]()

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

### Load and Search

Other than a `TableListBox` component, the `MusicLibrary` component also has two other important components described below:

1. **The load button**: This is a TextButton which when clicked prompts the user to select a file. Upon selection the file will be *appended to the end of the playlist* and the properties file (containing the playlist data) will also be **re-written with new playlist state** (R3A). The updating of the playlist file happens in a method called `MusicLibrary::updatePlaylistFile` which carries out the following main operations:

```cpp

// Clears the playlist file
playlistFile->clear();


// Inserts new data into playlist file
for (size_t i = 0; i < songs.size(); ++i)
{
    playlistFile->setValue(juce::String(i), songs[i]);
}
```

This method is called whenever there is change the `songs` vector in the memory to update the file on disk.

2. **A search box** (TextEditor): The user can start typing a track name in this box and the playlist will immediately updated to **show only the songs that contain the search query** (whatever the user has typed in the box). The main logic of this component is encapsulated in a method called `startSearch` which takes in the query string and filters the songs list (R3C):

```cpp

for (const auto& song : songs)
{
    if (song.containsIgnoreCase(searchString)) 
    {
        filteredSongs.push_back(song);
    }
}
```

When the user types something in the box, the music library component *goes into search mode*, i.e. the boolean variable `showingSearchResults` is set to `true`.

### The Pop Up Menu

A very common pattern I have observed in many GUI softwares is that, whenever there is a list of things, the user can right click on a single row of the list and a *contextual menu pops up* (pop up menu). The menu provides the user with some actions that can be performed for that particular row.

I have implemented the same thing in the music library component using `juce::PopupMenu` class and by overriding `cellClicked`. The screenshot below shows the pop up menu:

![ScreenShot of the Pop Up menu]()

Here is a detailed description of what happens when a particular option is selected from the pop up menu:

1. **Load in Player 1**: It is very clear from the text what will happen if this option is selected: this particular track will be loaded in Player 1 (or Deck 1).

2. **Load in Player 2**: Selecting this option loads the track in player 2. (R3D)

3. **Move Up**: The playlist I maintain in memory (and also the file on the disk) is **ordered**. The user can easily keep her/his tracks in order. If this option is selected, that specific track is moved up in the playlist. The logic behind this is simple: two elements of the `songs` vector get swapped:

```cpp
// Swap current row with row above (if any)
if (rowNumber >= 1)
{
    juce::String temp = songs[rowNumber];
    songs[rowNumber] = songs[rowNumber - 1];
    songs[rowNumber - 1] = temp;
}
```

4. **Move Down**: This does the exact opposite of the **Move Up** option: **moves the track down one position** (if it is not the bottom most).

5. **Remove**: Removes the track from the playlist.

The method `updatePlaylistState()` is called to update the state of the music library. This method **updates the `TableListBox` component**, **calls `repaint()`** function and also **calls the `updatePlaylistFile()` method** discussed above. 

I have created an `enum` called `PopUpOption` to relate the above options to integers which are used in the `cellClicked` method to detect which one of the options was clicked and then perform the action associated with that option:

```cpp

// MusicLibrary.h

enum PopUpOption
{
    LOAD_IN_1 = 1,
    // ....
    REMOVE = 4
};

// MusicLibrary.cpp

void MusicLibrary::cellClicked(...)
{
    // ...
    // If right clicked
    // show the pop up menu and capture the result
    result = playlistControlMenu->show();

    // Perform action based on result
    if (result == PopUpOption::LOAD_IN_1)
    {
        // ...
    }

    // ...
}
```

## R4: The New GUI Layout

I have tried to give the User Interface a complete overhaul using different **colors**, a **new layout** and also **resizable panels**.

A *difference between the old and the new GUI* can easily be observed by seeing the screenshots below:

![Screenshot of Old GUI]()

![Screenshot of the New GUI]()

Two `juce::LookAndFeel_V4` objects are used to **apply color theme** to the GUI. 
One is created and applied to the `MainComponent` itself and other one (called `playlistComponentTheme`) in the `MusicLibrary` component. Both the objects are private to thier respective component classes.

There are private methods called `setCustomTheme` in both the above mentioned components to apply colors to different types of component parts. The `setColour()` method is called on the `LookAndFeel_V4` object to set colors for different UI specifications. The below code snippet shows the setting of some colours:

```cpp
// MainComponent.h
private:
    // ...
    juce::LookAndFeel_V4 themeData;
    // ...

// MainComponent.cpp
void MainComponent::setCustomTheme()
{
    // primaryColor = juce::Colours::rebeccapurple
    themeData.setColour(juce::Slider::thumbColourId, primaryColor);
    themeData.setColour(
        juce::Slider::ColourIds::textBoxTextColourId, 
        juce::Colours::white
    );
    // ...
}
```

# Conclusion

## References

## Links