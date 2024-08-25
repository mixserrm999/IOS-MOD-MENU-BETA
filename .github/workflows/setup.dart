name: Auto NIC packager

# On every push
on:
  push:
    branches: [ main ]
    paths:
      - "template/*"

jobs:
  packager:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3
      env:
        VERSION: ""
    - name: Install Theos
      run: |
        sudo apt-get install fakeroot git perl clang build-essential -y
        echo "export THEOS=~/theos" >> ~/.profile
        source ~/.profile
        git clone --recursive https://github.com/theos/theos.git $THEOS
        
        curl https://kabiroberai.com/toolchain/download.php?toolchain=ios-linux -Lo toolchain.tar.gz
        tar xzf toolchain.tar.gz -C $THEOS/toolchain
        rm toolchain.tar.gz
        
        curl -LO https://github.com/theos/sdks/archive/master.zip
        TMP=$(mktemp -d)
        unzip master.zip -d $TMP
        mv $TMP/sdks-master/*.sdk $THEOS/sdks
        rm -r master.zip $TMP
      
    - name: Get version
      run: echo "VERSION=$(cat ./template/versionCheck.sh | sed -n 2p | tail -c 7 | head -c 5)" >> $GITHUB_ENV

    - name: Make NIC package
      run: |
        source ~/.profile
        rm ./iOS-Mod-Menu-Template-for-Theos.nic.tar || true # To force it to not fail even if the file does not exist
        $THEOS/bin/nicify.pl ./template
        
    - name: Upload artifact
      uses: actions/upload-artifact@v1.0.0
      with:
        name: "SERMIX MOD MENU v${{ env.VERSION }}.nic.tar"
        path: "./SERMIX MOD MENU v${{ env.VERSION }}.nic.tar"
        
    - name: Create Release
      id: create-release
      uses: actions/create-release@latest
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      with:
        tag_name: ${{ env.VERSION }}
        release_name: Release ${{ env.VERSION }}
        body: ""
        draft: false
        prerelease: false
    
    - name: Add Package to release
      uses: actions/upload-release-asset@v1
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      with:
        upload_url: ${{ steps.create-release.outputs.upload_url }}
        asset_path: "./SERMIX MOD MENU v${{ env.VERSION }}.nic.tar"
        asset_name: "SERMIX MOD MENU v${{ env.VERSION }}.nic.tar"
        asset_content_type: application/x-tar

    - name: Send file to Telegram
      run: |
        curl -F chat_id="${{ secrets.TELEGRAM_CHAT_ID }}" -F document=@"./SERMIX MOD MENU v${{ env.VERSION }}.nic.tar" -F caption="New release: SERMIX MOD MENU v${{ env.VERSION }}" "https://api.telegram.org/bot${{ secrets.TELEGRAM_BOT_TOKEN }}/sendDocument"
          
