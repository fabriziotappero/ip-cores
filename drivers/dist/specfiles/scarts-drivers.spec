Summary: SCARTS Drivers
Name: scarts-drivers
Version: 1.0.0
Release: 1
Source0: %{name}-%{version}.tar.gz
License: GPL
Group: Development/Tools
BuildRoot: /var/tmp/%{name}-buildroot 
BuildRequires: scarts-gcc >= 4.1.1
Requires: scarts-gcc >= 4.1.1
%define debug_package %{nil}
%define __strip /bin/true

%description
SCARTS Drivers

%prep
%setup -q -n %{name}-%{version}

%build
make


%install
rm -rf $RPM_BUILD_ROOT
make install PREFIX=$RPM_BUILD_ROOT/opt/scarts_toolchain


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root)
#%doc AUTHORS COPYING  README NEWS
/*

%changelog
* Mon Apr 04 2010 Jakob Lechner
- Initial build.

