## Installation
1. __Install Git.__ This step can be skipped with Git already installed. Use the following command to install or update Git:

    ```
    sudo apt install git
    ```

2. __Obtain the source code.__ Use the following command to obtain source code from GitHub:

    ```
    git clone https://github.com/ehennes775/ginstlog.git
    ```

3. __Prepare the build.__ Enter the project directory and prepare the build using the following two commands:

    ```
    cd ginstlog
    ./autogen.sh
    ```

4. __Configure the build.__ Configure the build using the following command:    

    ```
    ./configure
    ```

5. __Build from source.__ Build the program using the following command:

    ```
    make
    ```

6. __Install.__ Install the program using the following command:    
    
    ```
    sudo make install
    ```
