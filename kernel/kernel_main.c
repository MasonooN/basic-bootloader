void kernel_main() {
    const char* message = "Hello CPU, from the kernel."; // I just put a basic message here because... why not?
    char* video_memory = (char*)0xb8000;
    unsigned short offset = 0;

    // Loop through each character to display it on the screen.
    while(*message) {
        video_memory[offset++] = *message; // Write the character to the screen
        video_memory[offset++] = 0x07;
    }

    while(1) {}
}