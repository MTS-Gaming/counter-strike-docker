FROM debian:bullseye

ARG steam_user=anonymous
ARG steam_password=
ARG metamod_version=1.20
ARG amxmod_version=1.8.2

RUN apt update && apt install -y lib32gcc-s1 curl

# Install SteamCMD
RUN mkdir -p /opt/steam && cd /opt/steam && \
    curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

# Install HLDS
RUN mkdir -p /opt/hlds
# Workaround for "app_update 90" bug, see https://forums.alliedmods.net/showthread.php?p=2518786 and https://forums.alliedmods.net/showthread.php?t=319117
WORKDIR /opt/steam
RUN /opt/steam/steamcmd.sh +force_install_dir /opt/hlds +login $steam_user $steam_password +app_update 90 validate +quit || :; \
    /opt/steam/steamcmd.sh +force_install_dir /opt/hlds +login $steam_user $steam_password +app_update 70 validate +quit || :; \
    /opt/steam/steamcmd.sh +force_install_dir /opt/hlds +login $steam_user $steam_password +app_update 10 validate +quit || :; \
    /opt/steam/steamcmd.sh +force_install_dir /opt/hlds +login $steam_user $steam_password +app_update 90 validate +quit || :; \
    /opt/steam/steamcmd.sh +force_install_dir /opt/hlds +login $steam_user $steam_password +app_update 90 validate +quit || :; \
    /opt/steam/steamcmd.sh +force_install_dir /opt/hlds +login $steam_user $steam_password +app_update 90 validate +quit || :; \
    /opt/steam/steamcmd.sh +force_install_dir /opt/hlds +login $steam_user $steam_password +app_update 90 validate +quit || :; \
    /opt/steam/steamcmd.sh +force_install_dir /opt/hlds +login $steam_user $steam_password +app_update 90 validate +quit || :; \
    /opt/steam/steamcmd.sh +force_install_dir /opt/hlds +login $steam_user $steam_password +app_update 90 validate +quit && \
    mkdir -p ~/.steam && ln -s /opt/hlds ~/.steam/sdk32 && \
    ln -s /opt/steam/ /opt/hlds/steamcmd
ADD files/steam_appid.txt /opt/hlds/steam_appid.txt
ADD hlds_run.sh /bin/hlds_run.sh
RUN chmod +x /bin/hlds_run.sh

# Add default config
ADD files/server.cfg /opt/hlds/cstrike/server.cfg

# Add maps
ADD maps/* /opt/hlds/cstrike/maps/
ADD files/mapcycle.txt /opt/hlds/cstrike/mapcycle.txt

# Install metamod
RUN mkdir -p /opt/hlds/cstrike/addons/metamod/dlls && \
    curl -sqL "http://prdownloads.sourceforge.net/metamod/metamod-$metamod_version-linux.tar.gz?download" | tar -C /opt/hlds/cstrike/addons/metamod/dlls -zxvf -
ADD files/liblist.gam /opt/hlds/cstrike/liblist.gam
# Remove this line if you aren't going to install/use amxmodx and dproto
ADD files/plugins.ini /opt/hlds/cstrike/addons/metamod/plugins.ini

# Install dproto
RUN mkdir -p /opt/hlds/cstrike/addons/dproto
ADD files/dproto_i386.so /opt/hlds/cstrike/addons/dproto/dproto_i386.so
ADD files/dproto.cfg /opt/hlds/cstrike/dproto.cfg

# Install AMX mod X
RUN curl -sqL "http://www.amxmodx.org/release/amxmodx-$amxmod_version-base-linux.tar.gz" | tar -C /opt/hlds/cstrike/ -zxvf - && \
    curl -sqL "http://www.amxmodx.org/release/amxmodx-$amxmod_version-cstrike-linux.tar.gz" | tar -C /opt/hlds/cstrike/ -zxvf -
ADD files/maps.ini /opt/hlds/cstrike/addons/amxmodx/configs/maps.ini

# Cleanup
RUN apt remove -y curl

WORKDIR /opt/hlds

ENTRYPOINT ["/bin/hlds_run.sh"]
