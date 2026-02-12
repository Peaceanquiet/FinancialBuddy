# Introduction 
The Personal Finance & Budget Tracking Application is a mobile application designed to help users monitor their spending, manage budgets, and better understand their financial habits. Many individuals, especially students and young professionals, struggle to track expenses consistently and lack clear visibility into where their money is going. This application aims to provide a simple, secure, and accessible solution to that problem.

The primary objective of this project is to develop a cross-platform mobile application using Flutter that allows users to record expenses, organize spending into categories, and view summarized financial information. The application will include a secure backend for storing user data and will follow industry best practices for authentication, data protection, and software development workflows.

This project also serves as a practical implementation of modern software engineering principles, including version control with Git, collaborative development using Azure DevOps, Agile sprint planning, and structured repository organization. By the end of development, the application will provide users with a reliable tool for improving financial awareness and making informed budgeting decisions.


# Getting Started

This section explains how to install the required tools, clone the repository, and run the application on your local machine.

## Installation Process

Follow these steps to set up the development environment:

1. Install Flutter SDK  
   Download Flutter from the official website:  
   https://docs.flutter.dev/get-started/install

2. Install Android Studio  
   Download and install Android Studio from:  
   https://developer.android.com/studio

3. Install required Android Studio components  
   During installation or first launch, ensure the following are installed:
   - Android SDK
   - Android SDK Command-line Tools
   - Android Emulator
   - Android SDK Platform Tools

4. Install Flutter and Dart plugins in your IDE  
   If using Visual Studio Code:
   - Open VS Code
   - Go to Extensions
   - Install:
     - Flutter extension
     - Dart extension

   If using Android Studio:
   - Go to Plugins
   - Install Flutter (this will also install Dart)

5. Verify installation  
   Open a terminal and run:

   ```bash
   flutter doctor

## Git Process

This project uses Git and Azure DevOps for version control and collaboration. The following steps describe the standard workflow from opening the project in Visual Studio Code to submitting and merging changes.

### 1. Open the Project in Visual Studio Code

Open Visual Studio Code.

Click:

File → Open Folder → Select the repository folder

Open the terminal:

Terminal → New Terminal

### 2. Ensure Local Repository is Up to Date

Switch to the main branch:

git checkout main

Pull the latest changes from Azure DevOps:

git pull

Check the repository status:

git status

Create and switch to a new branch:

git checkout -b branch_name

EXAMPLE:
git checkout -b README_Update_Emily

To stage all modified files:

git add .

OR stage a specific file:

git add fileName

Commit saves your staged changes locally with a message describing what was changed:

git commit -m "message"

Push your branch to the remote repository so others can see your changes:

git push -u origin branch_name

//THE -u makes the branch remote so it will go into DevOps Azure, without the -u tag all commits will be local ONLY

Once approved, the Pull Request will be merged into the main branch.
After merge, update your local repository:

git checkout main
git pull


# Build and Test
TODO: Describe and show how to build your code and run the tests. 

# Contribute
Contribution Guidelines:

    - Do not commit directly to the main branch

    - Always create a new branch for new work

    - Use clear and descriptive commit messages

    - Ensure your changes do not break existing functionality

    - Link Pull Requests to the appropriate Product Backlog Item when applicable