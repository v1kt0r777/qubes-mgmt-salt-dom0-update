%{!?version: %define version %(cat version)}
%{!?rel: %define rel %(cat rel)}

Name:      qubes-mgmt-salt-dom0-update
Version:   %{version}
Release:   %{rel}%{?dist}
Summary:   Custom 'pkg' module that enables state files to install or update packages in dom0
License:   GPL 2.0
URL:	   http://www.qubes-os.org/

Group:     System administration tools
BuildArch: noarch
Requires:  qubes-mgmt-salt
Requires:  qubes-mgmt-salt-dom0

%define _builddir %(pwd)

%description
Custom 'pkg' module that enables state files to install or update packages in dom0

%prep
# we operate on the current directory, so no need to unpack anything
# symlink is to generate useful debuginfo packages
rm -f %{name}-%{version}
ln -sf . %{name}-%{version}
%setup -T -D

%build

%install
make install DESTDIR=%{buildroot} LIBDIR=%{_libdir} BINDIR=%{_bindir} SBINDIR=%{_sbindir} SYSCONFDIR=%{_sysconfdir}

%post
# Update Salt Configuration
qubesctl state.sls config -l quiet --out quiet > /dev/null || true
qubesctl saltutil.clear_cache -l quiet --out quiet > /dev/null || true
qubesctl saltutil.sync_all refresh=true -l quiet --out quiet > /dev/null || true

# Enable Test States
#qubesctl top.enable %{state_name}.tests saltenv=test -l quiet --out quiet > /dev/null || true

%files
%defattr(-,root,root)
%doc LICENSE README.rst
%attr(750, root, root) %dir /srv/salt/_modules
/srv/salt/_modules/qubes_dom0_update.py*

%attr(750, root, root) %dir /srv/formulas/test/update-formula
/srv/formulas/test/update-formula/LICENSE
/srv/formulas/test/update-formula/README.rst
/srv/formulas/test/update-formula/update/tests.sls
/srv/formulas/test/update-formula/update/tests.top

%changelog
