#include "../include.h"
#include "Settings.h"
#include <chrono>
// here create your menu

int tab = 0;
bool welcome = true;

void debugLog(const char *message)
{
    if (!debug) return;

    float startTime = ImGui::GetTime();
    float endTime = 5.0f; // Time to disappear welcome message

    if (startTime < endTime)
    {
        static auto startTime = std::chrono::high_resolution_clock::now();
        auto now = std::chrono::high_resolution_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(now - startTime);
        float animProgress = (float)duration.count() / 700.0f; // Animation duration of 700ms

        if (animProgress > 1.0f)
        {
            animProgress = 1.0f;
        }

        // Get the current window size
        ImVec2 windowSize = ImGui::GetIO().DisplaySize;

        // Calculate the size of the text
        ImVec2 textSize = ImGui::CalcTextSize(message);

        // Calculate the position for the welcome message
        float xPos = (windowSize.x - textSize.x) * 0.5f; // Centered horizontally
        float yPos = (windowSize.y - textSize.y) * 0.5f; // Centered vertically

        // Set ImGui window flags to make the welcome message non-interactive
        ImGuiWindowFlags window_flags = ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_NoInputs |
                                        ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoSavedSettings |
                                        ImGuiWindowFlags_NoFocusOnAppearing | ImGuiWindowFlags_NoNav;

        ImGui::SetNextWindowPos(ImVec2(xPos, yPos), ImGuiCond_Always);
        ImGui::Begin("Mod Menu", nullptr, window_flags);

        ImGui::SetNextWindowBgAlpha(animProgress);
        // Render the welcome message text
        ImGui::TextColored(ImVec4(0.0f, 1.0f, 0.0f, 1.0f), "DEBUG LOG");
        ImGui::Text("%s", message);

        // End the ImGui window
        ImGui::End();
    }
}

void drawWelcome(const char *message, const char* gameInfo, const char* author)
{

    float startTime = ImGui::GetTime();
    float endTime = 5.0f; //Time to disappear welcome message

    if (startTime < endTime && welcome)
    {

        static auto startTime = std::chrono::high_resolution_clock::now();
        auto now = std::chrono::high_resolution_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(now - startTime);
        float animProgress = (float)duration.count() / 700.0f; // Animation duration of 700ms

        if (animProgress > 1.0f)
        {
            animProgress = 1.0f;
        }

        // Get the current window size
        ImVec2 windowSize = ImGui::GetIO().DisplaySize;

        // Calculate the size of the text
        ImVec2 textSize = ImGui::CalcTextSize(message);

        // Calculate the position for the welcome message
        float xPos = (windowSize.x - textSize.x) * 0.5f; // Centered horizontally
        float yPos = (windowSize.y - textSize.y) * 0.5f; // Centered vertically

        // Set ImGui window flags to make the welcome message non-interactive
        ImGuiWindowFlags window_flags = ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_NoInputs |
                                        ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoSavedSettings |
                                        ImGuiWindowFlags_NoFocusOnAppearing | ImGuiWindowFlags_NoNav;

        // Begin a new ImGui window
        ImGui::SetNextWindowPos(ImVec2(xPos, yPos), ImGuiCond_Always);
        ImGui::Begin("Mod Menu", nullptr, window_flags);

        ImGui::SetNextWindowBgAlpha(animProgress);

        // Render the welcome message text
        ImGui::TextColored(ImVec4(0.0f, 1.0f, 0.0f, 1.0f), "Injection Successful");
        ImGui::Text("%s", message);

        if (gameInfo && strlen(gameInfo) > 0)
            {
                ImGui::Separator();
                ImGui::TextColored(ImVec4(0.0f, 1.0f, 0.0f, 1.0f), "Mod Info: ");
                ImGui::SameLine();
                ImGui::TextWrapped("%s", gameInfo);
            }

            if (author && strlen(author) > 0)
            {
                ImGui::Separator();
                ImGui::TextColored(ImVec4(0.0f, 1.0f, 0.0f, 1.0f), "Made by %s", author);
            }

        // End the ImGui window
        ImGui::End();
    } else {
        welcome = false;
    }
}

void drawMenu(bool MenDeal)
{
    static bool animating = true;
    static bool wasMenuOpen = false;
    static auto startTime = std::chrono::high_resolution_clock::now();

    if (MenDeal)
    {
        if (!wasMenuOpen)
        {
            startTime = std::chrono::high_resolution_clock::now();
            animating = true;
            wasMenuOpen = true;
        }

        auto now = std::chrono::high_resolution_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(now - startTime);
        float animProgress = (float)duration.count() / 700.0f; // Animation duration of 700ms

        if (animProgress > 1.0f)
        {
            animProgress = 1.0f;
            animating = false;
        }

        ImVec2 windowSize = ImVec2(350, 250);
        ImGui::SetNextWindowBgAlpha(animProgress);

        if (animating)
        {
            ImGui::SetNextWindowSize(windowSize, ImGuiCond_Always);

            // Slide-down effect
            ImVec2 startPos = ImVec2((ImGui::GetIO().DisplaySize.x - windowSize.x) / 2, -windowSize.y);
            ImVec2 endPos = ImVec2((ImGui::GetIO().DisplaySize.x - windowSize.x) / 2, (ImGui::GetIO().DisplaySize.y - windowSize.y) / 2);
            ImVec2 windowPos = ImVec2(
                startPos.x + (endPos.x - startPos.x) * animProgress,
                startPos.y + (endPos.y - startPos.y) * animProgress);

            ImGui::SetNextWindowPos(windowPos, ImGuiCond_Always);
        }

        ImGui::Begin("@@APPNAME@@ Mod Menu", &MenDeal, ImGuiWindowFlags_NoCollapse); // No flags that disable dragging

        ImGui::Columns(2);
        ImGui::SetColumnOffset(1, 120);

        ImGui::Spacing();
        if (ImGui::Button("Memory", ImVec2(100.0f, 40.0f)))
        {
            tab = 0;
        }

        ImGui::Spacing();
        if (ImGui::Button("credit", ImVec2(100.0f, 40.0f)))
        {
            tab = 1;
        }

        ImGui::NextColumn();

        bool settingsChanged = false;

        switch (tab)
        {
        case 0: {
            ImGui::BeginChild("##scroll_memory", ImVec2(0, 0), true);
            ImGui::Text("Memory settings");
            ImGui::Separator();
            ImGui::Spacing();

            // Get the current time may real time.
            time_t currentTime = time(0);
            struct tm *localTime = localtime(&currentTime);
            char timeString[50];
            strftime(timeString, sizeof(timeString), "%H:%M:%S", localTime);

            // Show the time in the menu
            ImGui::Text("Current Time: %s", timeString);
            settingsChanged |= ImGui::Checkbox("Test 1", &test);
            settingsChanged |= ImGui::Checkbox("Test 2", &test2);

            ImGui::EndChild();
            break;
        }
        case 1:
            // เนื้อหาของแท็บข้อความ
            ImGui::BeginChild("##text_box", ImVec2(0, 0), true);
            ImGui::TextWrapped("นี่คือข้อความที่คุณต้องการแสดงในกล่องข้อความ คุณสามารถเพิ่มข้อความได้ตามต้องการ และถ้าข้อความยาวเกินไป มันจะแรปให้อัตโนมัติเมื่อใช้ฟังก์ชัน TextWrapped");
            
            ImGui::Spacing();
            ImGui::Separator();
            ImGui::Spacing();
            
            ImGui::Text("ข้อความเพิ่มเติม:");
            ImGui::BulletText("ข้อ 1: นี่คือรายละเอียดของข้อ 1");
            ImGui::BulletText("ข้อ 2: นี่คือรายละเอียดของข้อ 2");
            
            ImGui::Spacing();
            ImGui::Separator();
            ImGui::Spacing();
            
            // หากต้องการกล่องข้อความที่มีกรอบและพื้นหลัง
            ImGui::BeginChild("##framed_text", ImVec2(0, 100), true, ImGuiWindowFlags_NoMove);
            ImGui::TextWrapped("นี่คือกล่องข้อความที่มีกรอบและความสูงคงที่ คุณสามารถใส่ข้อความยาว ๆ ได้ที่นี่ และมันจะมีสกอลบาร์ถ้าข้อความยาวเกินขนาดที่กำหนด");
            
            ImGui::EndChild();
        break;
        }

        if (settingsChanged)
        {
            saveSettings();
        }

        ImGui::End();
    }
    else
    {
        wasMenuOpen = false;
    }
}



void drawButton()
{
    // Get the current window size
    ImVec2 windowSize = ImGui::GetIO().DisplaySize;

    // Calculate position for the floating button to be in the middle of the screen
    ImVec2 buttonPos = ImVec2((windowSize.x - 80.0f) * 0.5f, (windowSize.y - 30.0f) * 0.5f);

    // Set ImGui window flags to make the button non-interactive
    ImGuiWindowFlags window_flags = ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_NoInputs |
                                    ImGuiWindowFlags_NoSavedSettings | ImGuiWindowFlags_NoFocusOnAppearing |
                                    ImGuiWindowFlags_NoNav | ImGuiWindowFlags_NoMove;

    // Begin a new ImGui window for the floating button
    ImGui::SetNextWindowPos(buttonPos, ImGuiCond_Always, ImVec2(0.5f, 0.5f)); // Center the window
    ImGui::Begin("FloatingButton", nullptr, window_flags);

    // Render the floating button
    if (ImGui::Button("Menu", ImVec2(80.0f, 30.0f)))
    {
        drawMenu(true);
    }

    // End the ImGui window for the floating button
    ImGui::End();
}