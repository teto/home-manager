enableCalendars:
{ lib, ... }:
{
  accounts.calendar = {
    basePath = "calendars";
    accounts = {
      personal = { };
      work.local.path = "/srv/calendars/work";
      single.local = {
        type = "singlefile";
        path = "/srv/calendars/single.ics";
      };
    };
  };

  programs.noctalia = {
    enable = true;
    package = null;
    inherit enableCalendars;
    settings = lib.mkIf enableCalendars {
      calendar = {
        refresh_minutes = 30;
        account.work = {
          name = "Work calendar";
          color = "#abcdef";
        };
      };
    };
  };

  nmt.script =
    if enableCalendars then
      ''
        assertFileContent home-files/.config/noctalia/config.toml ${./expected-calendars.toml}
      ''
    else
      ''
        assertPathNotExists home-files/.config/noctalia/config.toml
      '';
}
