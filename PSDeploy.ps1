param (
    $RepositoryName = 'AshdarGallery'
)

Deploy 'LegacyData' {
    By PSGalleryModule {
        FromSource 'LegacyData'
        To $RepositoryName
        Tagged Ashdar, data
    }
}