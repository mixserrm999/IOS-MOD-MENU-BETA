# Define project name and other details directly
my $project_name = "SERMIX";
my $binary_name = "";
my $app_name = "SERMIX";
my $app_version = "0.1.0";
my $main_file = "Button";
my $site = "";

# Set these values as default in NIC prompts
NIC->prompt("BINARYNAME", "Enter binary name of the app (if you know it)", {default => $binary_name});
NIC->prompt("APPNAME", "Enter name of the app", {default => $app_name});
NIC->prompt("APPVERSION", "Enter current version of the app", {default => $app_version});
NIC->prompt("MAIN", "Enter the main .mm [Gestures/Button]", {default => $main_file});
NIC->prompt("SITE", "Enter the site where the hack is for", {default => $site});
