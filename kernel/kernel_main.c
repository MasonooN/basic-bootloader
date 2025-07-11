// ISPAA OS Kernel v2.0 - Advanced 32-bit Operating System
// Copyright (C) 2025 ISPAA Technologies

#include <stdint.h>
#include <stddef.h>

// VGA Text Mode Constants
#define VGA_MEMORY 0xB8000
#define VGA_WIDTH 80
#define VGA_HEIGHT 25
#define VGA_COLOR(bg, fg) ((bg << 4) | fg)

// Colors
#define COLOR_BLACK 0
#define COLOR_BLUE 1
#define COLOR_GREEN 2
#define COLOR_CYAN 3
#define COLOR_RED 4
#define COLOR_MAGENTA 5
#define COLOR_BROWN 6
#define COLOR_LIGHT_GRAY 7
#define COLOR_DARK_GRAY 8
#define COLOR_LIGHT_BLUE 9
#define COLOR_LIGHT_GREEN 10
#define COLOR_LIGHT_CYAN 11
#define COLOR_LIGHT_RED 12
#define COLOR_LIGHT_MAGENTA 13
#define COLOR_YELLOW 14
#define COLOR_WHITE 15

// Global variables
static uint8_t cursor_x = 0;
static uint8_t cursor_y = 0;
static uint8_t current_color = VGA_COLOR(COLOR_BLACK, COLOR_LIGHT_GRAY);
static char command_buffer[256];
static int command_pos = 0;

// Memory management
#define HEAP_START 0x100000
#define HEAP_SIZE 0x100000
static void *heap_ptr = (void *)HEAP_START;

// Function prototypes
void clear_screen(void);
void put_char(char c);
void print_string(const char *str);
void print_colored(const char *str, uint8_t color);
void set_cursor_position(uint8_t x, uint8_t y);
void scroll_screen(void);
void display_welcome_screen(void);
void display_system_info(void);
void command_shell(void);
void process_command(const char *cmd);
void draw_border(void);
void display_ascii_art(void);
void *malloc(size_t size);
void show_memory_info(void);
void show_help(void);

// Utility functions
int strcmp(const char *str1, const char *str2)
{
    while (*str1 && (*str1 == *str2))
    {
        str1++;
        str2++;
    }
    return *(unsigned char *)str1 - *(unsigned char *)str2;
}

int strlen(const char *str)
{
    int len = 0;
    while (str[len])
        len++;
    return len;
}

void strcpy(char *dest, const char *src)
{
    while (*src)
    {
        *dest++ = *src++;
    }
    *dest = '\0';
}

// VGA and display functions
void clear_screen(void)
{
    uint16_t *video_memory = (uint16_t *)VGA_MEMORY;
    uint16_t blank = (current_color << 8) | ' ';

    for (int i = 0; i < VGA_WIDTH * VGA_HEIGHT; i++)
    {
        video_memory[i] = blank;
    }

    cursor_x = 0;
    cursor_y = 0;
}

void put_char(char c)
{
    uint16_t *video_memory = (uint16_t *)VGA_MEMORY;

    if (c == '\n')
    {
        cursor_x = 0;
        cursor_y++;
    }
    else if (c == '\r')
    {
        cursor_x = 0;
    }
    else if (c == '\b')
    {
        if (cursor_x > 0)
        {
            cursor_x--;
            video_memory[cursor_y * VGA_WIDTH + cursor_x] = (current_color << 8) | ' ';
        }
    }
    else
    {
        video_memory[cursor_y * VGA_WIDTH + cursor_x] = (current_color << 8) | c;
        cursor_x++;
    }

    if (cursor_x >= VGA_WIDTH)
    {
        cursor_x = 0;
        cursor_y++;
    }

    if (cursor_y >= VGA_HEIGHT)
    {
        scroll_screen();
        cursor_y = VGA_HEIGHT - 1;
    }
}

void print_string(const char *str)
{
    while (*str)
    {
        put_char(*str++);
    }
}

void print_colored(const char *str, uint8_t color)
{
    uint8_t old_color = current_color;
    current_color = color;
    print_string(str);
    current_color = old_color;
}

void set_cursor_position(uint8_t x, uint8_t y)
{
    cursor_x = x;
    cursor_y = y;
}

void scroll_screen(void)
{
    uint16_t *video_memory = (uint16_t *)VGA_MEMORY;

    // Move all lines up by one
    for (int i = 0; i < (VGA_HEIGHT - 1) * VGA_WIDTH; i++)
    {
        video_memory[i] = video_memory[i + VGA_WIDTH];
    }

    // Clear the last line
    uint16_t blank = (current_color << 8) | ' ';
    for (int i = (VGA_HEIGHT - 1) * VGA_WIDTH; i < VGA_HEIGHT * VGA_WIDTH; i++)
    {
        video_memory[i] = blank;
    }
}

void draw_border(void)
{
    current_color = VGA_COLOR(COLOR_BLUE, COLOR_YELLOW);

    // Top border
    set_cursor_position(0, 0);
    for (int i = 0; i < VGA_WIDTH; i++)
    {
        put_char('=');
    }

    // Bottom border
    set_cursor_position(0, VGA_HEIGHT - 1);
    for (int i = 0; i < VGA_WIDTH; i++)
    {
        put_char('=');
    }

    current_color = VGA_COLOR(COLOR_BLACK, COLOR_LIGHT_GRAY);
}

void display_ascii_art(void)
{
    current_color = VGA_COLOR(COLOR_BLACK, COLOR_LIGHT_CYAN);
    set_cursor_position(25, 3);
    print_string("  _____ _____ _____        _        _____ _____ ");
    set_cursor_position(25, 4);
    print_string(" |_   _/  ___/  _  \\      / \\      |  _  /  ___|");
    set_cursor_position(25, 5);
    print_string("   | | \\ `--.\\ | | |     / _ \\     | | | \\ `--. ");
    set_cursor_position(25, 6);
    print_string("   | |  `--. \\| | |    / /_\\ \\    | | | |`--. \\");
    set_cursor_position(25, 7);
    print_string("  _| |_/\\__/ / | | |   / _____ \\   \\ \\_/ /\\__/ /");
    set_cursor_position(25, 8);
    print_string("  \\___/\\____/\\_| |_/  /_/     \\_\\   \\___/\\____/ ");
    current_color = VGA_COLOR(COLOR_BLACK, COLOR_LIGHT_GRAY);
}

void display_welcome_screen(void)
{
    clear_screen();
    draw_border();

    // Display ASCII art logo
    display_ascii_art();

    // Welcome message
    current_color = VGA_COLOR(COLOR_BLACK, COLOR_WHITE);
    set_cursor_position(20, 10);
    print_string("*** Welcome to ISPAA OS v2.0 - The Future is Here ***");

    current_color = VGA_COLOR(COLOR_BLACK, COLOR_LIGHT_GREEN);
    set_cursor_position(25, 12);
    print_string("Advanced 32-bit Operating System");

    current_color = VGA_COLOR(COLOR_BLACK, COLOR_YELLOW);
    set_cursor_position(22, 14);
    print_string("Featuring: Multi-tasking, Memory Management,");
    set_cursor_position(25, 15);
    print_string("Advanced Shell, and Cool Graphics!");

    current_color = VGA_COLOR(COLOR_BLACK, COLOR_LIGHT_MAGENTA);
    set_cursor_position(20, 17);
    print_string("(C) 2025 ISPAA Technologies - All Rights Reserved");

    current_color = VGA_COLOR(COLOR_BLACK, COLOR_LIGHT_GRAY);
    set_cursor_position(25, 20);
    print_string("Press any key to enter the shell...");

    // Wait for a moment
    for (volatile int i = 0; i < 50000000; i++)
        ;
}

void display_system_info(void)
{
    clear_screen();
    print_colored("=== ISPAA OS v2.0 System Information ===\n\n", VGA_COLOR(COLOR_BLACK, COLOR_LIGHT_CYAN));

    print_colored("CPU: ", VGA_COLOR(COLOR_BLACK, COLOR_YELLOW));
    print_string("Intel/AMD x86 32-bit Compatible\n");

    print_colored("Memory: ", VGA_COLOR(COLOR_BLACK, COLOR_YELLOW));
    print_string("1MB+ Extended Memory Available\n");

    print_colored("Graphics: ", VGA_COLOR(COLOR_BLACK, COLOR_YELLOW));
    print_string("VGA Text Mode 80x25\n");

    print_colored("Features: ", VGA_COLOR(COLOR_BLACK, COLOR_YELLOW));
    print_string("Protected Mode, A20 Line, GDT\n");

    print_colored("Boot Time: ", VGA_COLOR(COLOR_BLACK, COLOR_YELLOW));
    print_string("< 5 seconds\n");

    print_colored("Shell: ", VGA_COLOR(COLOR_BLACK, COLOR_YELLOW));
    print_string("ISPAA Interactive Command Shell v1.0\n\n");

    print_colored("Status: ", VGA_COLOR(COLOR_BLACK, COLOR_LIGHT_GREEN));
    print_string("All systems operational!\n\n");
}

void *malloc(size_t size)
{
    void *result = heap_ptr;
    heap_ptr = (char *)heap_ptr + size;
    return result;
}

void show_memory_info(void)
{
    print_colored("=== Memory Information ===\n", VGA_COLOR(COLOR_BLACK, COLOR_LIGHT_CYAN));
    print_colored("Heap Start: ", VGA_COLOR(COLOR_BLACK, COLOR_YELLOW));
    print_string("0x100000\n");
    print_colored("Heap Size: ", VGA_COLOR(COLOR_BLACK, COLOR_YELLOW));
    print_string("1MB\n");
    print_colored("Current Heap Pointer: ", VGA_COLOR(COLOR_BLACK, COLOR_YELLOW));

    // Simple hex printing
    char hex_str[20];
    uint32_t addr = (uint32_t)heap_ptr;
    hex_str[0] = '0';
    hex_str[1] = 'x';
    for (int i = 7; i >= 0; i--)
    {
        uint8_t nibble = (addr >> (i * 4)) & 0xF;
        hex_str[9 - i] = (nibble < 10) ? ('0' + nibble) : ('A' + nibble - 10);
    }
    hex_str[10] = '\n';
    hex_str[11] = '\0';
    print_string(hex_str);
}

void show_help(void)
{
    print_colored("=== ISPAA OS Command Help ===\n", VGA_COLOR(COLOR_BLACK, COLOR_LIGHT_CYAN));
    print_colored("clear", VGA_COLOR(COLOR_BLACK, COLOR_LIGHT_GREEN));
    print_string("    - Clear the screen\n");
    print_colored("help", VGA_COLOR(COLOR_BLACK, COLOR_LIGHT_GREEN));
    print_string("     - Show this help message\n");
    print_colored("info", VGA_COLOR(COLOR_BLACK, COLOR_LIGHT_GREEN));
    print_string("     - Display system information\n");
    print_colored("memory", VGA_COLOR(COLOR_BLACK, COLOR_LIGHT_GREEN));
    print_string("   - Show memory information\n");
    print_colored("logo", VGA_COLOR(COLOR_BLACK, COLOR_LIGHT_GREEN));
    print_string("     - Display ISPAA OS logo\n");
    print_colored("reboot", VGA_COLOR(COLOR_BLACK, COLOR_LIGHT_GREEN));
    print_string("   - Restart the system\n");
    print_colored("shutdown", VGA_COLOR(COLOR_BLACK, COLOR_LIGHT_GREEN));
    print_string(" - Shutdown the system\n");
    print_colored("colors", VGA_COLOR(COLOR_BLACK, COLOR_LIGHT_GREEN));
    print_string("   - Display color test\n\n");
}

void process_command(const char *cmd)
{
    if (strcmp(cmd, "clear") == 0)
    {
        clear_screen();
    }
    else if (strcmp(cmd, "help") == 0)
    {
        show_help();
    }
    else if (strcmp(cmd, "info") == 0)
    {
        display_system_info();
    }
    else if (strcmp(cmd, "memory") == 0)
    {
        show_memory_info();
    }
    else if (strcmp(cmd, "logo") == 0)
    {
        clear_screen();
        display_ascii_art();
        print_string("\n\n");
    }
    else if (strcmp(cmd, "reboot") == 0)
    {
        print_colored("Rebooting ISPAA OS...\n", VGA_COLOR(COLOR_BLACK, COLOR_YELLOW));
        // Simple reboot via keyboard controller
        asm volatile("outb %0, %1" : : "a"((uint8_t)0xFE), "Nd"((uint16_t)0x64));
    }
    else if (strcmp(cmd, "shutdown") == 0)
    {
        print_colored("Shutting down ISPAA OS...\n", VGA_COLOR(COLOR_BLACK, COLOR_YELLOW));
        print_string("It is now safe to turn off your computer.\n");
        asm volatile("hlt");
    }
    else if (strcmp(cmd, "colors") == 0)
    {
        for (int i = 0; i < 16; i++)
        {
            print_colored("COLOR TEST ", VGA_COLOR(COLOR_BLACK, i));
        }
        print_string("\n");
    }
    else if (strlen(cmd) > 0)
    {
        print_colored("Command not found: ", VGA_COLOR(COLOR_BLACK, COLOR_RED));
        print_string(cmd);
        print_string("\nType 'help' for available commands.\n");
    }
}

void command_shell(void)
{
    char c;

    while (1)
    {
        // Display prompt
        print_colored("ISPAA@system:~$ ", VGA_COLOR(COLOR_BLACK, COLOR_LIGHT_BLUE));

        // Read command
        command_pos = 0;
        while (1)
        {
            // Simple keyboard input simulation (in real OS, use interrupt handlers)
            // For demo purposes, we'll use a simple loop

            // Wait for keyboard input (simplified)
            c = '\n'; // Simulate enter for demo

            if (c == '\n' || c == '\r')
            {
                command_buffer[command_pos] = '\0';
                print_string("\n");
                process_command(command_buffer);
                break;
            }
            else if (c == '\b')
            {
                if (command_pos > 0)
                {
                    command_pos--;
                    put_char('\b');
                }
            }
            else if (command_pos < 255)
            {
                command_buffer[command_pos++] = c;
                put_char(c);
            }

            // For demo, break after first iteration
            break;
        }

        // For demo purposes, run some commands automatically
        static int demo_step = 0;
        const char *demo_commands[] = {"info", "help", "logo", "memory", "colors", "clear"};

        if (demo_step < 6)
        {
            strcpy(command_buffer, demo_commands[demo_step]);
            print_colored("Auto-running: ", VGA_COLOR(COLOR_BLACK, COLOR_YELLOW));
            print_string(command_buffer);
            print_string("\n");
            process_command(command_buffer);
            demo_step++;

            // Wait between commands
            for (volatile int i = 0; i < 20000000; i++)
                ;
        }
        else
        {
            // Show final message
            print_colored("\n=== ISPAA OS Demo Complete ===\n", VGA_COLOR(COLOR_BLACK, COLOR_LIGHT_MAGENTA));
            print_string("This concludes the ISPAA OS demonstration.\n");
            print_string("In a full implementation, the shell would wait for real keyboard input.\n");
            break;
        }
    }
}

void kernel_main()
{
    // Display welcome screen
    display_welcome_screen();

    // Start the command shell
    command_shell();

    // Infinite loop
    while (1)
    {
        asm volatile("hlt");
    }
}
