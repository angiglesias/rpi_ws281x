version.h : version
	@printf "/* Auto Generated Header built by version.mk - DO NOT MODIFY */\n" > $@
	@printf '\n' >> $@
	@printf '#ifndef __VERSION_H__\n' >> $@
	@printf '#define __VERSION_H__\n' >> $@
	@printf '\n' >> $@
	@printf "#define VERSION_MAJOR $(VERSION_MAJOR)\n" >> $@
	@printf "#define VERSION_MINOR $(VERSION_MINOR)\n" >> $@
	@printf "#define VERSION_MICRO $(VERSION_MICRO)\n" >> $@
	@printf '\n' >> $@
	@printf '#endif /* __VERSION_H__ */\n' >> $@
