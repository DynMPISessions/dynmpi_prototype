#location of this sh file
LOC=$(realpath $(dirname "${BASH_SOURCE[0]}"))

#load common file
source $LOC/../../../common.sh $@

#every syscheck script should set up an ERRORSTATE variable and return it on completion.
ERRORSTATE=0

#Component name for check
component="Intel(R) Inspector 2021.4"

#Global variable
found=1
not_found=0

#makes a request for the version of the operating system according to the incoming parameters
check_version_os()
{
    if [ "$1" = $redhat_file ]; then
        add_string=$query_redhat
    elif [ "$1" = $other_linux_file ]; then
        add_string=$query_otherlin
    fi
    for release in "$@"; do
        if [ $release != $redhat_file ] && [ $release != $other_linux_file ]; then
            release_ver=$(cat "$1" | grep -i "$add_string$release")
            if [ -n "${release_ver}" ]; then
                speak "OS version supported."
                unset add_string
                unset release
                unset release_ver
                return
            fi
        fi
    done
    ERRORSTATE=1
    unset add_string
    unset release
    unset release_ver
    echo "Error: $component does not support this version of OS."
}

#makes a request for the exist special files and call check version os with parameters.
CHECK_OS()
{
    #supported operating systems with versions
    ubuntu="16.04 18.04 19.04"
    rhel="7 8"
    centos="6 7 8"
    fedora="29 30"
    sles="12 15"
    debian="9 10"

    #files with versions of OS and additional parameter of request
    #example full request(Fedora 29): cat /etc/redhat-release | grep -i "release 29"
    redhat_file="/etc/redhat-release"
    query_redhat="release "
    other_linux_file="/etc/os-release"
    query_otherlin="VERSION_ID=\""

    if [ -f $redhat_file ]; then
        rhel_check=$(cat $redhat_file | grep -i "Red Hat Enterprise Linux")
        if [ -n "${rhel_check}" ]; then
            check_version_os $redhat_file $rhel
        fi
        unset rhel_check
        centos_check=$(cat $redhat_file | grep -i "CentOS")
        if [ -n "${centos_check}" ]; then
            check_version_os $redhat_file $centos
        fi
        unset centos_check
        fedora_check=$(cat $redhat_file | grep -i "Fedora")
        if [ -n "${fedora_check}" ]; then
            check_version_os $redhat_file $fedora
        fi
        unset fedora_check
    elif [ -f $other_linux_file ]; then
        sles_check=$(cat $other_linux_file | grep -i "SLES")
        if [ -n "${sles_check}" ]; then
            check_version_os $other_linux_file $sles
        fi
        debian_check=$(cat $other_linux_file | grep -i "NAME=\"Debian")
        if [ -n "${debian_check}" ]; then
            check_version_os $other_linux_file $debian
        fi
        unset debian_check
        ubuntu_check=$(cat $other_linux_file | grep -i "NAME=\"Ubuntu")
        if [ -n "${ubuntu_check}" ]; then
            check_version_os $other_linux_file $ubuntu
        fi
        unset ubuntu_check
    else
        ERRORSTATE=1
        echo "Error: $component does not support this OS."
    fi

    #unset variable
    unset ubuntu
    unset rhel
    unset centos
    unset fedora
    unset sles
    unset debian

    unset redhat_file
    unset query_redhat
    unset other_linux_file
    unset query_otherlin
}

COMPARE_VERSIONS()
{
    A_CV="$1"
    B_CV="$2"
    RESULT_CV=0

    if [ $(echo "$A_CV" | grep -v "\.") ] && [ $(echo "$B_CV" | grep -v "\.") ]; then
        if [ "$A_CV" -gt "$B_CV" ]; then
            RESULT_CV=1
        elif [ "$B_CV" -gt "$A_CV" ]; then
            RESULT_CV=255
        fi
        unset RESULT_CV
        unset A_CV
        unset B_CV
        return $RESULT_CV
    fi

    CA_CV="0"
    CB_CV="0"
    INDEX_CV=1

    while [ -n "$CA_CV" ] && [ -n "$CB_CV" ]; do
        CA_CV=$(echo "$A_CV" | cut -d'.' -f${INDEX_CV})
        CB_CV=$(echo "$B_CV" | cut -d'.' -f${INDEX_CV})
        if [ -n "$CA_CV" ] && [ -z "$CB_CV" ] ; then
            RESULT_CV=1
        elif [ -z "$CA_CV" ] && [ -n "$CB_CV" ] ; then
            RESULT_CV=255
        elif [ -n "$CA_CV" ] && [ -n "$CB_CV" ] ; then
            if [ "$CA_CV" -gt "$CB_CV" ] ; then
                RESULT_CV=1
            elif [ "$CB_CV" -gt "$CA_CV" ] ; then
                RESULT_CV=255
            fi
            if [ $RESULT_CV -ne 0 ] ; then
                break
            fi
        fi
    INDEX_CV=$(($INDEX_CV+1))
    done

    unset CA_CV
    unset CB_CV
    unset A_CV
    unset B_CV
    unset INDEX_CV
    unset RESULT_CV
    return $RESULT_CV
}

CHECK_RPM()
{
    RPM_OS=0
    RPM_TOOL=`type -P rpm 2>&1`
    if [ -n "$RPM_TOOL" ]; then
        RPM_COMMAND=`rpm -q rpm > /dev/null 2>&1`
        RETCODE=$?
        if [ $RETCODE -eq 0 ]; then
            speak "rpm package found. rpm tool is '$RPM_TOOL'"
            RPM_OS=1
            return $RPM_OS
        else
            speak "rpm tool cannot locate the rpm package."
        fi
    fi
}

CHECK_DPKG()
{
    PKG_OS=0
    DPKG_TOOL=`type -P dpkg-query 2>&1`
    if [ -n "$DPKG_TOOL" ]; then
        DPKG_COMMAND=`dpkg-query -W dpkg > /dev/null 2>&1`
        if [ $? -eq 0 ]; then
            speak "dpkg package found."
            DPKG_OS=1
            return $DPKG_OS
        else
            speak "dpkg-query tool cannot find dpkg package."
        fi
    fi
}

CHECK_GTK3()
{
    GTK3_STATUS=$not_found
    if [ "$1" = $found ] ; then
        VT_QUERY_RESULT=`rpm -qa | grep 'gtk3'`
        if [ $? -eq 0 ]; then
            speak "Found GTK3 package."
            GTK3_STATUS=$found
        else
            VT_QUERY_RESULT=`rpm -qa | grep 'libgtk-3'`
            if [ $? -eq 0 ]; then
                speak "Found GTK3 package."
                GTK3_STATUS=$found
            else
                echo "Cannot find GTK3 package."
                GTK3_STATUS=$not_found
            fi
        fi
    elif [ "$2" = $found ] ; then
        VT_QUERY_RESULT=`dpkg-query -W 'libgtk-3*'`
        if [ $? -eq 0 ]; then
            speak "Found GTK3 package."
            GTK3_STATUS=$found
        else
            echo "Cannot find GTK3 package."
            GTK3_STATUS=$not_found
        fi
    else
        echo "Cannot find GTK3 package (no RPM or DPKG packages found)."
        GTK3_STATUS=$not_found
    fi
    return $GTK3_STATUS
}

CHECK_XSS()
{
    if [ "$1" = $found ] ; then
        VT_QUERY_RESULT=`rpm -qa | grep 'libXScrnSaver'`
        if [ $? -eq 0 ]; then
            speak "Found libXScrnSaver package."
            XSS_STATUS=$found
        else
            VT_QUERY_RESULT=`rpm -qa | grep 'libXss1'`
            if [ $? -eq 0 ]; then
                speak "Found libXScrnSaver package."
                XSS_STATUS=$found
            else
                echo "Cannot find libXScrnSaver/libXss1 package."
                XSS_STATUS=$not_found
            fi
        fi
    elif [ "$2" = $found ] ; then
        VT_QUERY_RESULT=`dpkg-query -W 'libxss1*'`
        if [ $? -eq 0 ]; then
            speak "Found libXScrnSaver package."
            XSS_STATUS=$found
        else
            echo "Cannot find libXss1 package."
            XSS_STATUS=$not_found
        fi
    else
        echo "Cannot find libXScrnSaver/libXss1/libxss1 package (no RPM or DPKG packages found)."
        XSS_STATUS=$not_found
    fi
    return $XSS_STATUS
}

CHECK_NSS_VERSION()
{
    version_nss="3.22"
    if [ "$1" = $found ] ; then
        NSS_VERSION=""
        VT_QUERY_RESULT=`rpm -q --qf "%{VERSION}\n" nss`
        if [ $? -eq 0 ]; then
            NSS_VERSION=$(echo "$VT_QUERY_RESULT" | head -1)
            speak "Found nss library: version=$NSS_VERSION."
        else
            VT_QUERY_RESULT=`rpm -q --qf "%{VERSION}\n" mozilla-nss`
            if [ $? -eq 0 ]; then
                NSS_VERSION=$(echo "$VT_QUERY_RESULT" | head -1)
                speak "Found mozilla-nss library: version=$NSS_VERSION."
            fi
        fi
        if [ "" != "$NSS_VERSION" ]; then
            COMPARE_VERSIONS "$NSS_VERSION" "$version_nss"
            NSS_RESULT=$?
            if [ $NSS_RESULT -eq 255 ]; then
                NSS_STATUS=$not_found
                echo "nss version is older than $version_nss."
            else
                NSS_STATUS=$found
            fi
        else
            echo "Cannot find nss library in the system."
            NSS_STATUS=$not_found
        fi
    elif [ "$2" = $found ] ; then
        VT_QUERY_RESULT=`dpkg-query -W -f '${Version}' libnss3`
        if [ $? -eq 0 ]; then
            NSS_VERSION=`echo $VT_QUERY_RESULT | cut -d'-' -f1`
            speak "Found libnss3 library: version=$NSS_VERSION."
            if [ -n "$(echo "$NSS_VERSION" | grep ':')" ]; then
                NSS_VERSION=$(echo "$NSS_VERSION" | cut -d':' -f2)
                speak "Corrected libnss3 version=$NSS_VERSION."
            fi

            COMPARE_VERSIONS "$NSS_VERSION" "$version_nss"
            NSS_RESULT=$?
            if [ $NSS_RESULT -eq 255 ]; then
                NSS_STATUS=$not_found
                echo "libnss3 version is older than $version_nss."
            else
                NSS_STATUS=$found
            fi
        else
            echo "Cannot find libss3 library in the system."
            NSS_STATUS=$not_found
        fi
    else
        echo "Cannot find nss library (no RPM or DPKG packages found)."
        NSS_STATUS=$non_found
    fi
    return $NSS_STATUS
}

CHECK_ASOUND_LIBRARY()
{
    if [ "$1" = $found ] ; then
        VT_QUERY_RESULT=`rpm -qa | grep 'alsa-lib-1'`
        if [ $? -eq 0 ]; then
            speak "Found asound library (alsa-lib)."
            LIBASOUND_STATUS=$found
        else
            VT_QUERY_RESULT=`rpm -qa | grep 'libasound'`
            if [ $? -eq 0 ]; then
                speak "Found asound library (libasound)."
                LIBASOUND_STATUS=$found
            else
                echo "Cannot find asound library."
                LIBASOUND_STATUS=$not_found
            fi
        fi
    elif [ "$2" = $found ] ; then
        VT_QUERY_RESULT=`dpkg-query -W 'libasound2*'`
        if [ $? -eq 0 ]; then
            speak "Found asound library."
            LIBASOUND_STATUS=$found
        else
            echo "Cannot find asound library."
            LIBASOUND_STATUS=$not_found
        fi
    else
        echo "Cannot find asound library (no RPM or DPKG packages found)."
        LIBASOUND_STATUS=$not_found
    fi
    return $LIBASOUND_STATUS
}

CHECK_XORG()
{
    if [ "$1" = $found ] ; then
        VT_QUERY_RESULT=`rpm -qa | grep 'xorg-x11-server'`
        if [ $? -eq 0 ]; then
            speak "Found Xorg server package."
            XORG_STATUS=$found
        else
            echo "Cannot find Xorg server package."
            XORG_STATUS=$not_found
        fi
    elif [ "$2" = $found ] ; then
        VT_QUERY_RESULT=`dpkg-query -W 'xserver-xorg'`
        if [ $? -eq 0 ]; then
            speak "Found Xorg server package."
            XORG_STATUS=$found
        else
            echo "Cannot find Xorg server package."
            XORG_STATUS=$not_found
        fi
    else
        echo "Cannot find Xorg server package (no RPM or DPKG packages found)."
        XORG_STATUS=$not_found
    fi
    return $XORG_STATUS
}

CHECK_PANGO_LIBRARY()
{
    if [ "$1" = $found ] ; then
        VT_QUERY_RESULT=`rpm -qa | grep 'pango-1'`
        if [ $? -eq 0 ]; then
            speak "Found pango library."
            LIBPANGO_STATUS=$found
        else
            echo "Cannot find pango library."
            LIBPANGO_STATUS=$not_found
        fi
    elif [ "$2" = $found ] ; then
        VT_QUERY_RESULT=`dpkg-query -W 'libpango-1*'`
        if [ $? -eq 0 ]; then
            speak "Found pango library."
            LIBPANGO_STATUS=$found
        else
            echo "Cannot find pango library."
            LIBPANGO_STATUS=$not_found
        fi
    else
        echo "Cannot find pango library (no RPM or DPKG packages found)."
        LIBPANGO_STATUS=$not_found
    fi
    return $LIBPANGO_STATUS
}

CHECK_GUI_PREREQUISITES()
{
    CHECK_RPM
    rpm_os_result=$?
    CHECK_DPKG
    dpkg_os_result=$?
    if [ "${rpm_os_result}" = $found ] || [ "${dpkg_os_result}" = $found ]; then
        CHECK_GTK3 $rpm_os_result $dpkg_os_result
        gtk3_status=$?
        CHECK_XSS $rpm_os_result $dpkg_os_result
        xss_status=$?
        CHECK_NSS_VERSION $rpm_os_result $dpkg_os_result
        nss_status=$?
        CHECK_ASOUND_LIBRARY $rpm_os_result $dpkg_os_result
        libasound_status=$?
        CHECK_XORG $rpm_os_result $dpkg_os_result
        xorg_status=$?
        CHECK_PANGO_LIBRARY $rpm_os_result $dpkg_os_result
        pango_status=$?
        if [ "$libasound_status" = "$found" ] && [ "$gtk3_status" = "$found" ] && [ "$xss_status" = "$found" ] \
            && [ "$nss_status" = "$found" ] && [ "$xorg_status" = "$found" ] && [ "$pango_status" = "$found" ]; then
            speak "Completed checking GUI prerequisites for $component."
        else
            echo "Warning: Requirements for running $component GUI are not met. Only command line interface will be available. For system requirements, see $component Release Notes"
        fi
    else 
        echo "Cannot find RPM or DPKG packages to check GUI prerequisites for $component."
    fi
}

CHECK_KERNEL_VERSION()
{
    vt_kernel_version="2.6.9"
    cur_kernel_version=`uname -r | cut -d'-' -f1`

    COMPARE_VERSIONS "$cur_kernel_version" "$vt_kernel_version"
    VT_RESULT=$?
    if [ $VT_RESULT -eq 255 ]; then
        echo "Error: Kernel version is older than $vt_kernel_version."
        ERRORSTATE=1
    else
        speak "Version of kernel is correct"
    fi
    unset cur_kernel_version
    unset VT_RESULT
    unset vt_kernel_version
}


GET_KERNEL_SRC_DIR()
{
    KERNEL_VERSION=`uname -r`
    if [ "auto" = "${LI_AMPLIFIER_KERNEL_SRC_DIR}" ] ; then
        KERNEL_SRC_DIR="/usr/src/linux-${KERNEL_VERSION}"
    fi

    if [ -r "${KERNEL_SRC_DIR}/include/linux/version.h" ] ; then
        if [ ! -d "${KERNEL_SRC_DIR}/include/asm" ] && [ ! -L "${KERNEL_SRC_DIR}/include/asm" ] ; then
            KERNEL_SRC_DIR=none
        fi
    else
        KERNEL_SRC_DIR=none
    fi

    KERNEL_26X=$(echo "$KERNEL_VERSION" | grep 2.6)
    if [ ! -d "${KERNEL_SRC_DIR}" ] ; then
        KERNEL_SRC_DIR="/lib/modules/${KERNEL_VERSION}/build"
        if [ ! -d "${KERNEL_SRC_DIR}" ] ; then
            KERNEL_SRC_DIR="/lib/modules/${KERNEL_VERSION}/source"
            if [ ! -d "${KERNEL_SRC_DIR}" ] ; then
                KERNEL_SRC_DIR="/usr/lib/modules/${KERNEL_VERSION}/build"
                if [ ! -d "${KERNEL_SRC_DIR}" ] ; then
                    KERNEL_SRC_DIR="/usr/lib/modules/${KERNEL_VERSION}/source"
                    if [ ! -d "${KERNEL_SRC_DIR}" ] ; then
                        if [ -n "${KERNEL_26X}" ] ; then
                            KERNEL_SRC_DIR="/usr/src/linux-2.6"
                        else
                            KERNEL_SRC_DIR="/usr/src/linux-3.0"
                        fi
                        if [ ! -d "${KERNEL_SRC_DIR}" ] ; then
                            KERNEL_SRC_DIR="/usr/src/linux"
                            if [ ! -d "${KERNEL_SRC_DIR}" ] ; then
                                KERNEL_SRC_DIR=none
                                echo "Warning: Unable to build drivers. No headers are located for this kernel version."
                            fi
                        fi
                    fi
                fi
            fi
        fi
    fi
    speak "Found correct kernel headers"
    unset KERNEL_SRC_DIR
    unset KERNEL_VERSION
    unset KERNEL_26X
}

CHECK_KERNEL()
{
    CHECK_KERNEL_VERSION
    GET_KERNEL_SRC_DIR
}

CHECK_GLIBC_VERSION()
{
    vt_status_glibc=0
    vt_cur_ver_lib="2.3.4"
    if [ "$1" = $found ] ; then
        VT_GLIBC_VERSION=`rpm -q --qf "%{VERSION}\n" glibc`
        if [ $? -eq 0 ]; then
            VT_GLIBC_VERSION=$(echo "$VT_GLIBC_VERSION" | head -1)
            speak "Found glibc library: version=$VT_GLIBC_VERSION."

            COMPARE_VERSIONS "$VT_GLIBC_VERSION" "$vt_cur_ver_lib"
            VT_RESULT=$?
            if [ $VT_RESULT -eq 255 ]; then
                echo "Error: glibc library version is older than $vt_cur_ver_lib."
                vt_status_glibc=1
            else
                speak "glibc library version is correct."
            fi
        else
            echo "Error: Cannot find glibc library in the system."
            vt_status_glibc=1
        fi
    elif [ "$2" = $found ] ; then
        QUERY_RESULT=`dpkg-query -W -f '${Version}' libc6`
        if [ $? -eq 0 ]; then
            VT_GLIBC_VERSION=`echo $QUERY_RESULT | cut -d'-' -f1`
            speak "Found libc6 library: version=$VT_GLIBC_VERSION."

            COMPARE_VERSIONS "$VT_GLIBC_VERSION" "$vt_cur_ver_lib"
            VT_RESULT=$?
            if [ $VT_RESULT -eq 255 ]; then
                echo "Error: glibc library version is older than $vt_cur_ver_lib."
                vt_status_glibc=1
            else
                speak "glibc library version is correct."
            fi
        else
            echo "Error: Cannot find libc6 library in the system."
            vt_status_glibc=1
        fi
    else
        echo "Error: Cannot find glibc version (no RPM or DPKG packages found)."
        vt_status_glibc=1
    fi

    unset VT_GLIBC_VERSION
    unset VT_RESULT
    unset vt_cur_ver_lib
    return $vt_status_glibc
}

CHECK_GLIBC()
{
    CHECK_GLIBC_VERSION $rpm_os_result $dpkg_os_result
    if [ $? = 1 ]; then
        ERRORSTATE=1
    fi
}

#main checks
CHECK_OS
CHECK_GUI_PREREQUISITES
CHECK_KERNEL
CHECK_GLIBC

#unset global variable
unset found
unset not_found

#always return ERRORSTATE ( which is 0 if no error )
return $ERRORSTATE
