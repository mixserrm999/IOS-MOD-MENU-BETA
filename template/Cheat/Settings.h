#ifndef SETTINGS_H
#define SETTINGS_H

// Define keys for user defaults
#define c0f1 @"case0_func1"
#define c0f2 @"case0_func2"

static bool debug = false;
//Here store your settings
static bool case0_func1 = false;
static bool case0_func2 = false;


void saveSettings(void) {
    //add your settings key
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setBool:case0_func1 forKey:c0f1];
    [defaults setBool:case0_func2 forKey:c0f2];
    
    [defaults synchronize];
}

void loadSettings(void) {
    //define your setting by key
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    case0_func1 = [defaults boolForKey:c0f1];
    case0_func2 = [defaults boolForKey:c0f2];
}



#endif // SETTINGS_H