SUFFIX := $(shell echo $(CC) | awk -F- '{print $$NF}')
PREFIX := $(CC:-$(SUFFIX)=)

ifeq ($(PREFIX),$(CC))
deb: deb_local
endif

ifneq ($(PREFIX),$(CC))
deb: deb_crossbuild deb_local
endif

deb_local: shared
	$(HIDE)mkdir -p build/libws2811-local_$(VERSION)
	$(HIDE)$(INSTALL) -d -m0755 build/libws2811-local_$(VERSION)/DEBIAN
	$(HIDE)$(INSTALL) -m0755 DEBIAN/* build/libws2811-local_$(VERSION)/DEBIAN/
	$(HIDE)$(INSTALL) -d -m0755 build/libws2811-local_$(VERSION)/usr/lib
	$(HIDE)$(INSTALL) -m0755 build/libws2811.so  build/libws2811-local_$(VERSION)/usr/lib/
	$(HIDE)$(DPKG_BUILD) build/libws2811-local_$(VERSION)

deb_crossbuild: shared
	$(HIDE)mkdir -p build/libws2811-local_$(VERSION)
	$(HIDE)$(INSTALL) -d -m0755 build/libws2811-cross_$(VERSION)/DEBIAN
	$(HIDE)$(INSTALL) -m0755 DEBIAN/* build/libws2811-cross_$(VERSION)/DEBIAN/
	$(HIDE)$(INSTALL) -d -m0755 build/libws2811-cross_$(VERSION)/usr/$(PREFIX)/include
	$(HIDE)$(INSTALL) -m0644 ws2811.h rpihw.h pwm.h build/libws2811-cross_$(VERSION)/usr/$(PREFIX)/include

	$(HIDE)$(INSTALL) -d -m0755 build/libws2811-cross_$(VERSION)/usr/lib/$(PREFIX)
	$(HIDE)$(INSTALL) -m0644 build/libws2811.so  build/libws2811-cross_$(VERSION)/usr/lib/$(PREFIX)
	$(HIDE)$(INSTALL) -m0644 build/libws2811.a  build/libws2811-cross_$(VERSION)/usr/lib/$(PREFIX)
	$(HIDE)$(INSTALL) -d -m0755 build/libws2811-cross_$(VERSION)/usr/lib/$(PREFIX)/pkgconfig
	sed -i 's/libws2811/libws2811-dev/g' build/libws2811-cross_$(VERSION)/DEBIAN/control
	
	$(eval pkg_path := $(shell echo "build/libws2811-cross_$(VERSION)/usr/lib/$(PREFIX)/pkgconfig/libws2811.pc"))
	@printf 'bindir=/usr/bin\n' > $(pkg_path)
	@printf "libdir=/usr/lib/$(PREFIX)\n" >> $(pkg_path)
	@printf 'includedir=/usr/include\n' >> $(pkg_path)
	@printf '\n' >> $(pkg_path)
	@printf 'Name: libws2811\n' >> $(pkg_path)
	@printf "Version: $(VERSION)\n" >> $(pkg_path)
	@printf "Description: $(DESCRIPTION)\n" >> $(pkg_path)
	@printf 'Libs: -L$${libdir} -lws2811 -lrt\n' >> $(pkg_path)
	@printf 'Cflags: -I/usr/$(PREFIX)/include\n' >> $(pkg_path)
	$(HIDE)$(DPKG_BUILD) build/libws2811-cross_$(VERSION)

clean_pkg:
	@rm -rf $(BUILDDIR)/libws2811-local_$(VERSION)
	@rm -rf $(BUILDDIR)/libws2811-cross_$(VERSION)
	@rm -f $(BUILDDIR)/libws2811*.deb

