# fixme: This doesn't support the 3.0.0 "GitLab" version
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