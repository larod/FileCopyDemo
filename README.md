# FileCopyManager
Welcome To My FileCopyManager Project

Apple hasn't provided an API for a file copy operation with progress callback. The only option devs have to get this functionality is to use a lower level API, in this case copyfile(3). As always, Apple's documentation is scarce and there are no real examples on how to use this API to achieve the desired functionality. I started to work on this project with the goal of creating a couple of classes that could be easily integrated with any project and provide that familiar Finder's file copy manager. This project is not perfect and needs some work but is a start. It works well with files, I haven't tested or implemented folder handling yet. Is still a work in progress but if you want to contribute you are more than welcome to do so. The FileOperation class that wraps copyfile(3) is based on the implementation of @rustle, you can get it here, I highly recommend to study his project. Rustle's implementation is geared towards a terminal application but the FileCopyOperation class is more complete and can handle folders.

I spent many hours trying to save people's time, if you wish to contribute you are more than welcome to do so. If you have any comments or ways to make this project better please send me a note. Thanks!

<img src="http://i.imgur.com/Pg5wEp0.png" alt="">
