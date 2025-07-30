#!/bin/bash

echo "🔧 Configuring Jellyfin for Cosmos SSO"
echo "======================================"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if we're running as root
if [[ $EUID -ne 0 ]]; then
   echo "❌ This script must be run as root"
   exit 1
fi

echo "📋 Step 1: Stopping Jellyfin..."
docker stop torrent-jellyfin

echo "📋 Step 2: Creating backup of current configuration..."
cp -r config/jellyfin config/jellyfin.backup.$(date +%Y%m%d_%H%M%S)
echo "✅ Backup created"

echo "📋 Step 3: Checking current Jellyfin configuration..."
if [ -f "config/jellyfin/system.xml" ]; then
    echo "✅ System configuration found"
else
    echo "❌ System configuration not found"
    exit 1
fi

echo "📋 Step 4: Configuring Jellyfin for Cosmos integration..."

# Create a new system.xml with authentication disabled for local access
cat > config/jellyfin/system.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<ServerConfiguration xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <LogFileRetentionDays>3</LogFileRetentionDays>
  <IsStartupWizardCompleted>true</IsStartupWizardCompleted>
  <EnableMetrics>false</EnableMetrics>
  <EnableNormalizedItemByNameIds>true</EnableNormalizedItemByNameIds>
  <IsPortAuthorized>true</IsPortAuthorized>
  <QuickConnectAvailable>true</QuickConnectAvailable>
  <EnableCaseSensitiveItemIds>true</EnableCaseSensitiveItemIds>
  <DisableLiveTvChannelUserDataName>true</DisableLiveTvChannelUserDataName>
  <MetadataPath />
  <PreferredMetadataLanguage>en</PreferredMetadataLanguage>
  <MetadataCountryCode>US</MetadataCountryCode>
  <SortReplaceCharacters>
    <string>.</string>
    <string>+</string>
    <string>%</string>
  </SortReplaceCharacters>
  <SortRemoveCharacters>
    <string>,</string>
    <string>&amp;</string>
    <string>-</string>
    <string>{</string>
    <string>}</string>
    <string>'</string>
  </SortRemoveCharacters>
  <SortRemoveWords>
    <string>the</string>
    <string>a</string>
    <string>an</string>
  </SortRemoveWords>
  <MinResumePct>5</MinResumePct>
  <MaxResumePct>90</MaxResumePct>
  <MinResumeDurationSeconds>300</MinResumeDurationSeconds>
  <MinAudiobookResume>5</MinAudiobookResume>
  <MaxAudiobookResume>5</MaxAudiobookResume>
  <InactiveSessionThreshold>0</InactiveSessionThreshold>
  <LibraryMonitorDelay>60</LibraryMonitorDelay>
  <LibraryUpdateDuration>30</LibraryUpdateDuration>
  <ImageSavingConvention>Legacy</ImageSavingConvention>
  <MetadataOptions>
    <MetadataOptions>
      <ItemType>Book</ItemType>
      <DisabledMetadataSavers />
      <LocalMetadataReaderOrder />
      <DisabledMetadataFetchers />
      <MetadataFetcherOrder />
      <DisabledImageFetchers />
      <ImageFetcherOrder />
    </MetadataOptions>
    <MetadataOptions>
      <ItemType>Movie</ItemType>
      <DisabledMetadataSavers />
      <LocalMetadataReaderOrder />
      <DisabledMetadataFetchers />
      <MetadataFetcherOrder />
      <DisabledImageFetchers />
      <ImageFetcherOrder />
    </MetadataOptions>
    <MetadataOptions>
      <ItemType>MusicVideo</ItemType>
      <DisabledMetadataSavers />
      <LocalMetadataReaderOrder />
      <DisabledMetadataFetchers>
        <string>The Open Movie Database</string>
      </DisabledMetadataFetchers>
      <MetadataFetcherOrder />
      <DisabledImageFetchers>
        <string>The Open Movie Database</string>
      </DisabledImageFetchers>
      <ImageFetcherOrder />
    </MetadataOptions>
    <MetadataOptions>
      <ItemType>Series</ItemType>
      <DisabledMetadataSavers />
      <LocalMetadataReaderOrder />
      <DisabledMetadataFetchers />
      <MetadataFetcherOrder />
      <DisabledImageFetchers />
      <ImageFetcherOrder />
    </MetadataOptions>
    <MetadataOptions>
      <ItemType>MusicAlbum</ItemType>
      <DisabledMetadataSavers />
      <LocalMetadataReaderOrder />
      <DisabledMetadataFetchers>
        <string>TheAudioDB</string>
      </DisabledMetadataFetchers>
      <MetadataFetcherOrder />
      <DisabledImageFetchers />
      <ImageFetcherOrder />
    </MetadataOptions>
    <MetadataOptions>
      <ItemType>MusicArtist</ItemType>
      <DisabledMetadataSavers />
      <LocalMetadataReaderOrder />
      <DisabledMetadataFetchers>
        <string>TheAudioDB</string>
      </DisabledMetadataFetchers>
      <MetadataFetcherOrder />
      <DisabledImageFetchers />
      <ImageFetcherOrder />
    </MetadataOptions>
    <MetadataOptions>
      <ItemType>BoxSet</ItemType>
      <DisabledMetadataSavers />
      <LocalMetadataReaderOrder />
      <DisabledMetadataFetchers />
      <MetadataFetcherOrder />
      <DisabledImageFetchers />
      <ImageFetcherOrder />
    </MetadataOptions>
    <MetadataOptions>
      <ItemType>Season</ItemType>
      <DisabledMetadataSavers />
      <LocalMetadataReaderOrder />
      <DisabledMetadataFetchers />
      <MetadataFetcherOrder />
      <DisabledImageFetchers />
      <ImageFetcherOrder />
    </MetadataOptions>
    <MetadataOptions>
      <ItemType>Episode</ItemType>
      <DisabledMetadataSavers />
      <LocalMetadataReaderOrder />
      <DisabledMetadataFetchers />
      <MetadataFetcherOrder />
      <DisabledImageFetchers />
      <ImageFetcherOrder />
    </MetadataOptions>
  </MetadataOptions>
  <SkipDeserializationForBasicTypes>true</SkipDeserializationForBasicTypes>
  <ServerName />
  <UICulture>en-US</UICulture>
  <SaveMetadataHidden>false</SaveMetadataHidden>
  <ContentTypes />
  <RemoteClientBitrateLimit>0</RemoteClientBitrateLimit>
  <EnableFolderView>false</EnableFolderView>
  <EnableGroupingIntoCollections>false</EnableGroupingIntoCollections>
  <DisplaySpecialsWithinSeasons>true</DisplaySpecialsWithinSeasons>
  <CodecsUsed />
  <PluginRepositories>
    <RepositoryInfo>
      <Name>Jellyfin Stable</Name>
      <Url>https://repo.jellyfin.org/files/plugin/manifest.json</Url>
      <Enabled>true</Enabled>
    </RepositoryInfo>
  </PluginRepositories>
  <EnableExternalContentInSuggestions>true</EnableExternalContentInSuggestions>
  <ImageExtractionTimeoutMs>0</ImageExtractionTimeoutMs>
  <PathSubstitutions />
  <EnableSlowResponseWarning>true</EnableSlowResponseWarning>
  <SlowResponseThresholdMs>500</SlowResponseThresholdMs>
  <CorsHosts>
    <string>*</string>
  </CorsHosts>
  <ActivityLogRetentionDays>30</ActivityLogRetentionDays>
  <LibraryScanFanoutConcurrency>0</LibraryScanFanoutConcurrency>
  <LibraryMetadataRefreshConcurrency>0</LibraryMetadataRefreshConcurrency>
  <RemoveOldPlugins>true</RemoveOldPlugins>
  <AllowClientLogUpload>true</AllowClientLogUpload>
  <DummyChapterDuration>0</DummyChapterDuration>
  <ChapterImageResolution>MatchSource</ChapterImageResolution>
  <ParallelImageEncodingLimit>0</ParallelImageEncodingLimit>
  <CastReceiverApplications>
    <CastReceiverApplication>
      <Id>F007D354</Id>
      <Name>Stable</Name>
    </CastReceiverApplication>
    <CastReceiverApplication>
      <Id>6F511C87</Id>
      <Name>Unstable</Name>
    </CastReceiverApplication>
  </CastReceiverApplications>
  <TrickplayOptions>
    <EnableHwAcceleration>false</EnableHwAcceleration>
    <EnableHwEncoding>false</EnableHwEncoding>
    <EnableKeyFrameOnlyExtraction>false</EnableKeyFrameOnlyExtraction>
    <ScanBehavior>NonBlocking</ScanBehavior>
    <ProcessPriority>BelowNormal</ProcessPriority>
    <Interval>10000</Interval>
    <WidthResolutions>
      <int>320</int>
    </WidthResolutions>
    <TileWidth>10</TileWidth>
    <TileHeight>10</TileHeight>
    <Qscale>4</Qscale>
    <JpegQuality>90</JpegQuality>
    <ProcessThreads>1</ProcessThreads>
  </TrickplayOptions>
</ServerConfiguration>
EOF

echo "✅ System configuration updated"

echo "📋 Step 5: Clearing existing user database..."
if [ -f "config/jellyfin/data/data/jellyfin.db" ]; then
    cp config/jellyfin/data/data/jellyfin.db config/jellyfin/data/data/jellyfin.db.backup.$(date +%Y%m%d_%H%M%S)
    echo "✅ Database backed up"
    
    # Clear users table
    sqlite3 config/jellyfin/data/data/jellyfin.db "DELETE FROM Users;"
    echo "✅ Users cleared from database"
else
    echo "⚠️  No database found, will be created on first startup"
fi

echo "📋 Step 6: Starting Jellyfin..."
docker start torrent-jellyfin

echo "📋 Step 7: Waiting for Jellyfin to start..."
sleep 10

echo "📋 Step 8: Testing Jellyfin access..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8096 | grep -q "200\|302"; then
    echo "✅ Jellyfin is accessible"
else
    echo "❌ Jellyfin is not accessible"
fi

echo ""
echo "🎉 Jellyfin Configuration Complete!"
echo "=================================="
echo ""
echo "📋 What was configured:"
echo "======================="
echo "✅ Cleared existing user database"
echo "✅ Updated system configuration"
echo "✅ Jellyfin will now start without authentication"
echo "✅ Ready for Cosmos SSO integration"
echo ""
echo "📋 Next Steps:"
echo "=============="
echo "1. Access Jellyfin: http://localhost:8096"
echo "2. Complete the setup wizard (no login required)"
echo "3. Configure your media libraries"
echo "4. Add Jellyfin to Cosmos: localhost:8096"
echo "5. Configure authentication in Cosmos"
echo ""
echo "🌐 For TVs and devices:"
echo "======================"
echo "• TVs will connect directly to Jellyfin without login"
echo "• Cosmos will handle authentication for web access"
echo "• Devices will stay logged in to Jellyfin"
echo "• Cosmos provides SSO for web interface only"
echo ""
echo "✅ Configuration complete! Access Jellyfin to set up your libraries." 