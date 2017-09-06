package pantallaPrincipal

import CopiarReceta.CopiarReceta
import ar.tp.dieta.Receta
import ar.tp.dieta.Usuario
import detalleReceta.DetalleReceta
import java.awt.Color
import java.util.ArrayList
import org.uqbar.arena.aop.windows.TransactionalDialog
import org.uqbar.arena.bindings.NotNullObservable
import org.uqbar.arena.layout.ColumnLayout
import org.uqbar.arena.layout.HorizontalLayout
import org.uqbar.arena.layout.VerticalLayout
import org.uqbar.arena.widgets.Button
import org.uqbar.arena.widgets.CheckBox
import org.uqbar.arena.widgets.Label
import org.uqbar.arena.widgets.Panel
import org.uqbar.arena.widgets.Selector
import org.uqbar.arena.widgets.TextBox
import org.uqbar.arena.widgets.TextFilter
import org.uqbar.arena.widgets.TextInputEvent
import org.uqbar.arena.widgets.tables.Column
import org.uqbar.arena.widgets.tables.Table
import org.uqbar.arena.windows.WindowOwner
import ar.tp.dieta.CriterioBusqueda

class PantallaPrincipal extends TransactionalDialog<PantallaPrincipalAplicationModel>{
	
	new(WindowOwner owner,Usuario usuario){
		super (owner, new PantallaPrincipalAplicationModel(usuario))
	}
	
	override protected createFormPanel(Panel mainPanel) {
		
		val elementSelected = new NotNullObservable("recetaSeleccionada")
		
		title = "Consulta de recetas"
		mainPanel.layout = new VerticalLayout
		
		val PanelConsulta = new Panel(mainPanel)
		PanelConsulta.layout = new ColumnLayout(2)
		val PanelIzq = new Panel(PanelConsulta)
		val PanelDerecho = new Panel(PanelConsulta)
		
		new Label(PanelIzq).text = "Nombre"
		new TextBox(PanelIzq) => [
			bindValueToProperty("busquedaUsuario.nombre")
			withFilter(new LetrasFilter)
			]
		new Label(PanelIzq).text = "Dificultad"
		new Selector<String>(PanelIzq) => [
			bindItemsToProperty("busquedaUsuario.dificultades")
			bindValueToProperty("busquedaUsuario.dificultad")
		]
		new Label(PanelIzq).text = "Que contenga ingrediente"
		new TextBox(PanelIzq) => [
			bindValueToProperty("busquedaUsuario.ingrediente")
			withFilter(new LetrasFilter)
			]
		
		new Label(PanelDerecho).text = "Calorias"
		
		val PanelCalorias = new Panel(PanelDerecho)
		PanelCalorias.layout = new HorizontalLayout
		
		new Label(PanelCalorias).text = "De "
		new TextBox(PanelCalorias) => [
			bindValueToProperty("busquedaUsuario.caloriasMinimas")
			withFilter(new NumeroFilter)
			]
		new Label(PanelCalorias).text = " a "
		new TextBox(PanelCalorias) => [
			bindValueToProperty("busquedaUsuario.caloriasMaximas")
			withFilter(new NumeroFilter)
			]
		
		new Label(PanelDerecho).text = "Temporada"
		new Selector<String> (PanelDerecho)=> [
			bindItemsToProperty("busquedaUsuario.temporadas")
			bindValueToProperty("busquedaUsuario.temporada")
		]
		
		val PanelFiltroUsuario = new Panel(PanelDerecho)
		PanelFiltroUsuario.layout = new HorizontalLayout
		
		new CheckBox(PanelFiltroUsuario) => [
			bindValueToProperty("busquedaUsuario.aplicarFiltro")	
		]
		
		new Label(PanelFiltroUsuario).text = "Aplicar filtros del perfil de usuario"
		
		val PanelBotoneraBusqueda = new Panel(PanelDerecho)
		PanelBotoneraBusqueda.layout = new HorizontalLayout	
		
		new Button(PanelBotoneraBusqueda) => [
			caption = "Buscar"
			onClick [ | 
				modelObject.limpiarRecetas
				modelObject.filtrar
				modelObject.busquedaUsuario = new CriterioBusqueda
				modelObject.mensaje = "Este es el resultado de su consulta"
			]
		]
		
		new Button(PanelBotoneraBusqueda) => [
			caption = "Volver"
			onClick [ | this.close()
				super.executeTask
			]
		]
				
		new Label(mainPanel).bindValueToProperty("mensaje")// = "Estas fueron sus ultimas consultas"
		grillaConsulta(mainPanel)
		val PanelBotonera = new Panel(mainPanel)
		PanelBotonera.layout = new HorizontalLayout
		new Button(PanelBotonera) => [
			caption = "Ver"
			onClick [ | this.verReceta()]
			bindEnabled(elementSelected)	
		]
		
		new Button(PanelBotonera) => [
			caption = "Favorita"
			onClick [ | modelObject.agregarORemoverRecetaFavorita
			]
			bindEnabled(elementSelected)
		] 
		
		new Button(PanelBotonera) => [
			caption = "Copiar receta"
			onClick [ | this.copiar()]
			bindEnabled(elementSelected)
		]
	}
	
	
	def grillaConsulta(Panel mainPanel){
			val grilla = new Table(mainPanel, typeof(Receta)) => [
				width = 400
				height = 2000
				bindItemsToProperty("recetas")
				bindValueToProperty("recetaSeleccionada")
			]
			new Column<Receta>(grilla) => [
				fixedSize = 200
				title = "Nombre"
				bindContentsToProperty("nombreDeLaReceta")
				colorear(it)
			]
			
			new Column<Receta>(grilla) => [
				fixedSize = 200
				title = "Calorias"
				bindContentsToProperty("calorias")
				colorear(it)
			]
			
			new Column<Receta>(grilla) => [
				fixedSize = 200
				title = "Dificultad"
				bindContentsToProperty("dificultadDePreparacion")
				colorear(it)
			]
			
			new Column<Receta>(grilla) => [
				fixedSize = 200
				title = "Temporada"
				bindContentsToProperty("temporadaALaQueCorresponde")
				colorear(it)
			]
		}
		
		def colorear(Column<Receta> it) {
			bindBackground("devolverme").transformer =
			[ Receta recibe | if (modelObject.usuario.misRecetas.contains(recibe)) Color.RED 
				else {if (modelObject.usuario.recetario.recetas.contains(recibe)) Color.GREEN
				else { Color.BLUE
					}
				}
			]
		}
		
		def void verReceta() {
			var temporal = new ArrayList<Receta>
			temporal.add(modelObject.recetaSeleccionada)
			modelObject.usuario.getObserverConsulta.seRealizoBusqueda(temporal)
			modelObject.usuario.agregarRecetasBuscadas(temporal)
			(new DetalleReceta(this, modelObject.recetaSeleccionada, modelObject.usuario)).open
		}
	
		def void copiar() {
			(new CopiarReceta(this, modelObject.recetaSeleccionada, modelObject.usuario)).open
		}
		
}

class NumeroFilter implements TextFilter {
	
	override accept(TextInputEvent event) {
		event.potentialTextResult.matches("[0-9,.]*")
	}		
}

class LetrasFilter implements TextFilter {
	override accept(TextInputEvent event) {
		event.potentialTextResult.matches("[a-zA-Z ]*")
	}		
}


