#ifndef SETTINGS_H
#define SETTINGS_H

// Define keys for user defaults
#define kTestKey @"test"
#define kTest2Key @"test2"

static bool debug = false;
//Here store your settings
static bool test = false;
static bool test2 = false;


void saveSettings(void) {
    //add your settings key
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setBool:test forKey:kTestKey];
    [defaults setBool:test2 forKey:kTest2Key];
    
    [defaults synchronize];
}

void loadSettings(void) {
    //define your setting by key
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    test = [defaults boolForKey:kTestKey];
    test2 = [defaults boolForKey:kTest2Key];
}



#endif // SETTINGS_H