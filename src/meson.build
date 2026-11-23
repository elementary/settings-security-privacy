pkgdatadir_declaration = configure_file(
    configuration: configuration_data,
    input: 'config.vala.in',
    output: '@BASENAME@'
)

plug_files = files(
    'Plug.vala',
    'UFWHelpers.vala',
    'DBus/PermissionStore.vala',
    'Views/FirewallPanel.vala',
    'Views/HouseKeepingPanel.vala',
    'Views/LockPanel.vala',
    'Widgets/AppRow.vala',
    'Views/LocationPanel.vala'
)

plug_dependencies = [
    dependency('gio-2.0'),
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('granite-7'),
    dependency('gtk4', version: '>= 4.10'),
    meson.get_compiler('vala').find_library('posix'),
    polkit_dep,
    switchboard_dep
]

if zeitgeist_dep.found()
    plug_files += files(
        'BlackList.vala',
        'ZGUtilities.vala',
        'Views/TrackPanel.vala',
        'Widgets/AppChooser.vala',
        'Widgets/ClearUsageDialog.vala',
        'Widgets/ExcludeTreeView.vala',
        'Widgets/IncludeTreeView.vala'
    )
    plug_dependencies += [zeitgeist_dep]
endif

shared_module(
    meson.project_name(),
    pkgdatadir_declaration,
    plug_files,
    plug_resources,
    dependencies: plug_dependencies,
    install: true,
    install_dir : pkgdatadir
)
