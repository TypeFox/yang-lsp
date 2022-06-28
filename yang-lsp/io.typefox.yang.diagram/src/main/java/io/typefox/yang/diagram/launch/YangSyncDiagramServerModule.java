package io.typefox.yang.diagram.launch;

import org.eclipse.sprotty.xtext.ls.SyncDiagramServerModule;
import org.eclipse.xtext.ide.server.LanguageServerImpl;

import io.typefox.yang.diagram.YangSyncDiagramLanguageServer;

public class YangSyncDiagramServerModule extends SyncDiagramServerModule {
	@Override
	public Class<? extends LanguageServerImpl> bindLanguageServerImpl() {
		return YangSyncDiagramLanguageServer.class;
	}
}
