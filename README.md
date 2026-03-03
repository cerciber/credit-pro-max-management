## 🚀 Credit Pro Max

¡Bienvenidos! 👋 

Soy Cesar Torres, candidato al rol de Líder Técnico en el Banco Caja Social. Este proyecto nace como parte de la **Prueba Técnica – Proceso de Selección Interno BCS – Líder Técnico Backend, Frontend y Liderazgo Técnico Integral**, y busca demostrar mediante un **caso de uso de credito digital** mi capacidad para diseñar y liderar soluciones end-to-end en un contexto bancario realista.  

Este caso de uso está pensado para demostrar cómo, utilizando agentes de inteligencia artifical y otra estrategias, es posible empezar a orquestar y automatizar de manera controlada el ciclo de vida del desarrollo de software. Esto no solo asegura mejores resultados en los equipos, sino que también permite enfocar los esfuerzos en lo que realmente importa: **la generación de valor**. 💎

<details>
<summary><strong>🧩 Necesidad y propuesta</strong></summary>

### Estado técnico actual

Actualmente contamos con **múltiples productos funcionando, en desarrollo y en evolución**, lo cual trae consigo una serie de fortalezas y también algunos retos importantes.

**Pros**

- Productos funcionando exitosamente.  
- Nuevos productos y evoluciones.  
- Infraestructura y base tecnológica común.  
- Personas que conocen los productos y que tienen la capacidad de gestionarlos y evolucionarlos.  
- Luz verde para integrar IA en nuestros procesos.  

**Contras**

- Entre más crece un producto, más difícil es de gestionar (foco en la evolución funcional y no en la evolución estructural).  
- Múltiples procesos y configuraciones duplicadas (cada producto ha evolucionado de forma independiente).  
- El personal no ha incrementado, pero sí ha incrementado la complejidad y la cantidad de desarrollo tecnológico (de nuevo, foco en la evolución funcional y no en la evolución estructural).  

Debemos llegar a un punto de equilibrio entre lo funcional y lo estructural, garantizando que nuestros logros alcanzados se mantengan.

---

### Propuestas técnicas para fortalecer nuestra parte estructural

Para abordar esta necesidad y lograr ese equilibrio entre lo funcional y lo estructural, mi propuesta se apoya en tres pilares complementarios:

1. **Git como mecanismo flexible de transversalidad**  
2. **AI Agents estándar y customizados como mecanismo de innovación**  
3. **E2E Testing como mecanismo de eficiencia**  

#### Git como mecanismo flexible de transversalidad

La idea con Git no es solo versionar código, sino construir **bases comunes** que actúen como “configuraciones padre” desde las que heredan nuestros servicios. Esto nos permite que cada equipo y cada producto sigan evolucionando a su propio ritmo, pero siempre con un punto de referencia claro sobre qué es común y qué es particular. Cuando aparecen diferencias, Git deja de ser solo una herramienta técnica y se convierte en un **“ojo absoluto, pero no restrictivo”**: nos muestra con precisión dónde nos estamos desviando y nos permite decidir, con calma y en el momento correcto, si esa diferencia debe mantenerse, alinearse o convertirse en un nuevo estándar. Es una estrategia **gradual y AI‑friendly**, pensada para convivir con el estado actual sin frenar la evolución, y que abre conversaciones concretas sobre cambios reales en lugar de discusiones abstractas sobre “cómo debería ser la configuración ideal”.

#### AI Agents estándar y customizados como mecanismo de innovación

En cuanto a IA, ya hemos dado varios pasos importantes: hay curiosidad, hay laboratorios, hay formación y existe luz verde para experimentar con herramientas y asistentes de código. Al mismo tiempo, la industria se está moviendo hacia modelos premium y **arquitecturas de AI Agents** que permiten orquestar y gobernar esos modelos de forma seria, alineada con las necesidades del negocio. La propuesta es dejar de ver la IA solo como “una herramienta que ayuda”, y empezar a tratarla como un **actor dentro del flujo de trabajo**, a través de agentes estándar y customizados que automaticen tareas completas: lectura de contexto, generación de código, refactor, creación de pruebas, documentación y certificación. Un ejemplo concreto es un **agente de desarrollo basado en un grafo de decisiones**, capaz de escoger rutas distintas según el tipo de necesidad (responder, desarrollar, certificar, hacer merge) y trabajar integrado con nuestros repositorios y pipelines. No se trata solo de escribir más rápido, sino de incorporar la IA en el diseño del propio proceso de desarrollo.

#### E2E Testing como mecanismo de eficiencia

Por el lado de las pruebas, hoy contamos con unitarias y buena cobertura, pero eso no siempre se traduce en la tranquilidad de que “todo funciona junto”: faltan bases de datos reales, entornos representativos e integraciones completas, y mucho del esfuerzo de QA sigue siendo manual, repetitivo y externo al flujo natural de DevOps. Apostarle a **E2E Testing** es cambiar esa conversación. Significa tener suites automatizadas que ejercitan el sistema de punta a punta, que viven dentro de los proyectos, que se corren en los pipelines y que usan tecnologías y estándares consistentes. Esto permite que los equipos de desarrollo validen por sí mismos el comportamiento real del sistema, mientras QA se enfoca en diseñar y certificar escenarios de negocio apoyados en automatización, en lugar de repetir pruebas manuales una y otra vez. El resultado es doble: **más confianza en cada despliegue** y **más tiempo disponible para pensar en nuevos escenarios y mejoras**, no solo en ejecutar checklists. En este contexto, el E2E se vuelve la pieza clave para certificar eficientemente los desarrollos y para sostener, en la práctica, todo lo que se construya con transversal Git y AI Agents.

</details>

<details>
<summary><strong>📦 Definición del sistema</strong></summary>

### Flujo de crédito digital preaprobado

Este sistema modela un **flujo de crédito digital preaprobado simplificado** del Banco Caja Social, pensado específicamente para créditos de libre inversión. La experiencia se organiza en una serie de vistas secuenciales que guían al cliente de forma clara y controlada a lo largo de todo el proceso:

- **Sign-in**: punto de entrada donde el usuario se identifica como cliente del banco y puede iniciar su experiencia de crédito digital.  
- **Login**: autenticación segura del cliente para acceder a la información de su preaprobado y a sus datos básicos.  
- **Personalizar oferta**: espacio donde el cliente ajusta monto, plazo y condiciones dentro de los rangos permitidos por su preaprobación.  
- **Cuentas**: selección o confirmación de la cuenta donde se realizará el desembolso y desde donde se gestionarán los pagos.  
- **Beneficiarios**: registro y validación de beneficiarios que participarán en la operación, cuando aplique.  
- **Aceptar oferta**: revisión final de términos y condiciones, simulaciones y desglose de la obligación, con la aceptación explícita del cliente.  
- **Firmar pagaré**: proceso de firma electrónica del pagaré y de los documentos legales asociados al crédito.  
- **OTC**: validaciones adicionales (por ejemplo, controles operativos y de seguridad) necesarias antes de habilitar el desembolso.  
- **Finalización**: pantalla de cierre donde se confirma el resultado de la solicitud y se entregan los siguientes pasos o canales de soporte.  

El propósito de este flujo es que un usuario, partiendo de una preaprobación, pueda **solicitar y formalizar un crédito de libre inversión 100% digital**, con todos los pasos necesarios para autenticarse, adaptar su oferta, definir dónde se gestionará el desembolso, registrar beneficiarios, aceptar condiciones, firmar electrónicamente los documentos requeridos y completar la operación de manera segura.

</details>

<details>
<summary><strong>🤖 Definición del AI Agent</strong></summary>

## 🎯 Resumen general

El **Developer Agent** es un sistema de automatización inteligente que acompaña el ciclo completo de desarrollo de software. Funciona en un bucle continuo que lee solicitudes del usuario, determina qué tipo de acción corresponde y ejecuta el flujo adecuado para cada caso.

## 🔄 Flujo de trabajo del agente

El agente opera en un ciclo continuo que:

1. **Lee los mensajes del usuario**: recibe historias de usuario o solicitudes técnicas desde el sistema.  
2. **Valida el tipo de acción**: determina qué tipo de acción debe ejecutarse según la naturaleza de la petición.  
3. **Ejecuta la acción**: dispara el flujo de trabajo correspondiente al tipo de acción identificado.  

### Diagrama de decisiones del agente

El siguiente diagrama muestra la estructura general del grafo de decisiones, enfocándose en los nodos principales de ejecución:

![AI Agent Decision Graph](public/ai-agent-graph.jpg)

## 🎬 Tipos de acciones

El agente soporta siete tipos principales de acción, alineados con el grafo de decisiones mostrado en la imagen:

### 📝 RESPONSE Action
- **Propósito**: entregar información o respuestas sin modificar el sistema.  
- **Qué hace**: analiza la solicitud, genera una respuesta usando IA y la devuelve al usuario, por ejemplo para aclarar requisitos o explicar decisiones técnicas.  

### 🔍 QUERY Action
- **Propósito**: generar y ejecutar consultas sobre el sistema apoyándose en su propia sintaxis y contratos.  
- **Qué hace**: construye scripts de consulta (por ejemplo, contra APIs, bases de datos o logs) usando el lenguaje y las convenciones del sistema, de forma que sea posible inspeccionar estados, datos y comportamientos sin necesidad de desarrollar nuevas funcionalidades.  

### 🛠️ DEVELOPMENT Action
- **Propósito**: ejecutar un ciclo de desarrollo controlado, desde la planificación hasta la generación de código y pruebas.  
- **Qué hace**: toma una historia de usuario, propone un plan, prepara rama y mensaje de commit, implementa los cambios necesarios y construye las pruebas unitarias asociadas, dejando el desarrollo listo para ser certificado.  

### ✅ CERTIFICATION Action
- **Propósito**: certificar y validar la calidad de los cambios antes de avanzar en el flujo.  
- **Qué hace**: corrige errores detectados, actualiza repositorios, ejecuta linters, corre pruebas unitarias y E2E, valida coberturas y estados de ejecución, y solo cuando todo está en verde permite continuar con las siguientes acciones de envío.  

### 🚀 SEND_TO_DEV Action
- **Propósito**: enviar cambios certificados hacia entornos o ramas de desarrollo.  
- **Qué hace**: integra los cambios en el contexto de desarrollo (por ejemplo, ramas de integración o ambientes dev) y deja listo el escenario para que el equipo continúe iterando.  

### 🧪 SEND_TO_QA Action
- **Propósito**: preparar y enviar cambios hacia los flujos de QA y certificación funcional.  
- **Qué hace**: orquesta la promoción de cambios hacia entornos de QA, dispara ejecuciones adicionales de pruebas si aplica y registra el estado para que el equipo de calidad pueda concentrarse en validar escenarios de negocio.  

### 📦 SEND_TO_PROD Action
- **Propósito**: apoyar la promoción final de los cambios hacia el entorno productivo.  
- **Qué hace**: coordina los pasos necesarios para llevar cambios ya certificados hasta producción (según las políticas del banco), asegurando trazabilidad y guardando evidencia de lo que se liberó y cómo se liberó.  

> **Nota**: en este caso de uso concreto de crédito digital, las acciones `SEND_TO_DEV`, `SEND_TO_QA` y `SEND_TO_PROD` sí hacen parte del diseño del agente, pero **no se ejecutan de extremo a extremo** porque la prueba no está conectada a Azure DevOps. Aun así, se incluyen para mostrar cómo sería posible **orquestar y controlar estos procesos completos sobre Azure** (ramas, pipelines, promociones entre entornos, etc.) usando el mismo grafo de decisiones.  

## 🔧 Capacidades clave del agente

- **Análisis inteligente de solicitudes**: entiende mensajes y contexto para determinar la acción adecuada.  
- **Desarrollo automatizado**: orquesta un ciclo de desarrollo casi completo apoyado en IA.  
- **Aseguramiento de calidad**: integra pruebas, linters y validación de cobertura.  
- **Manejo de errores**: detecta y corrige errores de forma iterativa dentro del flujo de certificación.  
- **Integración con Git**: gestiona ramas, commits y sincronización remota de forma automatizada.  
- **Comunicación continua**: mantiene informado al usuario durante todo el proceso, explicando qué está haciendo y cuáles son los resultados.  

## 🎯 Filosofía del agente

El Developer Agent está diseñado para **automatizar al máximo el proceso de desarrollo**, de manera que los equipos puedan enfocarse en la **generación de valor** y en la toma de decisiones, más que en tareas repetitivas. Desde la planificación hasta la certificación y el merge final, el agente busca mantener un estándar consistente de calidad y trazabilidad, actuando como un copiloto técnico que respeta los procesos pero que también habilita nuevas formas de trabajar con IA dentro del ciclo de desarrollo.

</details>

