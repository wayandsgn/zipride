{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  onEntrypointLoaded: async (engineInitializer) => {
    try {
      const appRunner = await engineInitializer.initializeEngine();
      await appRunner.runApp();
      clearTimeout(window.ziprideLoadTimer);
      document.getElementById('loading')?.remove();
    } catch (error) {
      clearTimeout(window.ziprideLoadTimer);
      document.getElementById('loading-text').textContent = 'Não foi possível abrir a demonstração. Confira sua conexão e tente novamente.';
      document.getElementById('retry').hidden = false;
      console.error(error);
    }
  }
});
