local function configure_project_base()
  -- Directories
  location "build/%{_ACTION}/"
  objdir "build/%{_ACTION}/%{cfg.platform}/%{cfg.buildcfg}/obj/"
  targetdir "bin/%{cfg.buildcfg}/"

  -- Single-value settings
  cdialect "C11"
  cppdialect "C++17"
  exceptionhandling "On"
  rtti "On"
  warnings "Default"
  staticruntime "On"

  -- List settings
  includedirs { "src/" }
  sysincludedirs { "src/" }

  -- Debug settings
  filter "configurations:Debug"
    optimize "Off"
    symbols "On"

  -- Release settings
  filter "configurations:Release"
  	optimize "Full"
  	symbols "On"

  -- Windows
  filter "system:windows"
    defines { "NOMINMAX", "WIN32_LEAN_AND_MEAN" }
    systemversion "latest"

  -- Reset filter
  filter{}
end

workspace "GameProject-0"
  startproject "Game"
  platforms { io.popen("uname -m", "r"):read("*l") }
  configurations { "Debug", "Release" }

group "ThirdParty"
  project "SDL"
    kind "StaticLib"
    configure_project_base()
    warnings "Off"
    includedirs { "third_party/SDL/include/" }
    files {
      "third_party/SDL/src/*.c",
      "third_party/SDL/src/*/*.c",
      "third_party/SDL/src/*/dummy/*.c",
      "third_party/SDL/src/render/software/*.c",
    }
    removefiles {
      "third_party/SDL/src/main/dummy/SDL_dummy_main.c",
    }
    -- Windows settings
    filter { "system:windows" }
      files {
        "third_party/SDL/src/*/windows/*.c",
        "third_party/SDL/src/audio/directsound/*.c",
        "third_party/SDL/src/audio/disk/*.c",
        "third_party/SDL/src/audio/wasapi/*.c",
        "third_party/SDL/src/audio/winmm/*.c",
        "third_party/SDL/src/joystick/hidapi/*.c",
        "third_party/SDL/src/render/direct3d/*.c",
        "third_party/SDL/src/render/direct3d11/*.c",
        "third_party/SDL/src/render/opengl/*.c",
        "third_party/SDL/src/render/opengles2/*.c",
        "third_party/SDL/src/thread/generic/SDL_syscond.c",
        "third_party/SDL/src/video/yuv2rgb/*.c",
      }
    -- Linux settings
    filter { "system:linux" }
      files {
        "third_party/SDL/src/*/unix/*.c",
        "third_party/SDL/src/*/linux/*.c",
        "third_party/SDL/src/render/opengl/*.c",
        "third_party/SDL/src/thread/pthread/*.c",
      }

  project "SDL_mixer"
    kind "StaticLib"
    configure_project_base()
    warnings "Off"
    defines { "MUSIC_OGG", "_USE_MATH_DEFINES" }
    includedirs {
      "third_party/SDL/include/",
      "third_party/SDL_mixer/",
      "third_party/SDL_mixer/external/libogg-1.3.2/include/",
      "third_party/SDL_mixer/external/libvorbis-1.3.5/include/",
      "third_party/SDL_mixer/external/libvorbis-1.3.5/lib/",
    }
    files {
      "third_party/SDL_mixer/*.c",
      "third_party/SDL_mixer/external/libogg-1.3.2/src/*c",
      "third_party/SDL_mixer/external/libvorbis-1.3.5/lib/*c",
    }
    excludes { "third_party/SDL_mixer/external/libvorbis-1.3.5/lib/psytune.c" }

group "Game"
  project "Game"
    kind "WindowedApp"
    configure_project_base()
    includedirs {
      "include",
      "third_party/SDL/include/",
      "third_party/SDL_mixer/",
    }
    debugdir "."
    files { "src/**.cpp", "include/**.h"  }
    links { "SDL", "SDL_mixer" }
    -- Visual studio settings
    filter "action:vs*"
      vpaths {
        ["Headers"] = { "include/**.h" },
        ["Sources"] = {"src/**.cpp"},
      }
    -- Windows settings
    filter { "system:windows" }
      links {
        "Winmm",
        "version",
        "Imm32",
        "Setupapi",
      }
