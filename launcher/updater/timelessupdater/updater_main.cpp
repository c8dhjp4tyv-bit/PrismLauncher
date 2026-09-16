// SPDX-FileCopyrightText: 2022 Rachel Powers <508861+Ryex@users.noreply.github.com>
//
// SPDX-License-Identifier: GPL-3.0-only

/*
 *  Timeless Launcher - Minecraft Launcher
 *  Copyright (C) 2022 Rachel Powers <508861+Ryex@users.noreply.github.com>
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, version 3.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 */

#include "TimelessUpdater.h"

#if defined Q_OS_WIN32
#include "console/WindowsConsole.h"
#endif

int main(int argc, char* argv[])
{
#if defined Q_OS_WIN32
    // attach the parent console if stdout not already captured
    console::WindowsConsoleGuard _consoleGuard;
#endif

    TimelessUpdaterApp wUpApp(argc, argv);

    switch (wUpApp.status()) {
        case TimelessUpdaterApp::Starting:
        case TimelessUpdaterApp::Initialized: {
            return wUpApp.exec();
        }
        case TimelessUpdaterApp::Failed:
            return 1;
        case TimelessUpdaterApp::Succeeded:
            return 0;
        default:
            return -1;
    }
}
