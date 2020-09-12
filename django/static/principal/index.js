$(document).ready(function () {
    //CanvasJS
    CanvasJS.addCultureInfo("es", {
        decimalSeparator: ",", // Observe ToolTip Number Format
        digitGroupSeparator: ".", // Observe axisY labels
        days: ["domingo", "lunes", "martes", "miércoles", "jueves", "viernes", "sábado"],
        shortMonths: ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"],
        months: ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"],
        saveJPGText: "Guardar como JPG",
        savePNGText: "Guardar como PNG",
        printText: "Impresión",
        rangeSelector: {
            fromText: "De",
            toText: "A",
            rangeText: "Rango"
        }
    });



    var options = {
        animationEnabled: true,
        culture: "es",
        theme: "light2",
        axisX: {
            crosshair: {
                enabled: true
            },
            valueFormatString: "MMM",
            tickThickness: 4
        },
        axisY: {
            crosshair: {
                enabled: true
            },
            prefix: "$",
            labelFormatter: addSymbols,
            tickLength: 15,
            interval: 5000,
            tickThickness: 2
        },
        toolTip: {
            shared: true
        },
        legend: {
            cursor: "pointer",
            itemclick: toggleDataSeries
        },
        data: [
            {
                color: "#43991F",
                type: 'area',
                markerBorderColor: "white",
                markerBorderThickness: 2,
                name: 'Ventas',
                showInLegend: true,
                xValueFormatString: "MMMM YYYY",
                yValueFormatString: "$#.##0",
                dataPoints: [
                    {x: new Date(2020, 0), y: 23454, indexLabel: "23.454$"},
                    {x: new Date(2020, 1), y: 13351, indexLabel: "13.351$"},
                    {x: new Date(2020, 2), y: 22456, indexLabel: "22.456$"},
                    {x: new Date(2020, 3), y: 35452, indexLabel: "35.452$"},
                    {x: new Date(2020, 4), y: 18494, indexLabel: "18.494$"},
                    {x: new Date(2020, 5), y: 31143, indexLabel: "31.143$"},
                    {x: new Date(2020, 6), y: 15454, indexLabel: "15.454$"},
                    {x: new Date(2020, 7), y: 19197, indexLabel: "19.197$"},
                ]
            },
            {
                color: "#EB0000",
                type: "line",
                name: "Gastos",
                showInLegend: true,
                yValueFormatString: "$#.##0",
                indexLabelFontColor: "#A80000",
                dataPoints: [
                    {x: new Date(2020, 0), y: 10454, indexLabel: "10.454$"},
                    {x: new Date(2020, 1), y: 9351, indexLabel: "9.351$"},
                    {x: new Date(2020, 2), y: 8456, indexLabel: "8.456$"},
                    {x: new Date(2020, 3), y: 11452, indexLabel: "11.452$"},
                    {x: new Date(2020, 4), y: 11494, indexLabel: "11.494$"},
                    {x: new Date(2020, 5), y: 10143, indexLabel: "10.143$"},
                    {x: new Date(2020, 6), y: 10454, indexLabel: "10.454$"},
                    {x: new Date(2020, 7), y: 7197, indexLabel: "7.197$"},
                ]
            }
        ]
    }

    $("#chartProductividad").CanvasJSChart(options);

    function addSymbols(e) {
        var suffixes = ["", "K", "M", "B"];
        var order = Math.max(Math.floor(Math.log(e.value) / Math.log(1000)), 0);
    
        if (order > suffixes.length - 1)
            order = suffixes.length - 1;
    
        var suffix = suffixes[order];
        return CanvasJS.formatNumber(e.value / Math.pow(1000, order)) + suffix;
    }
    
    function toggleDataSeries(e) {
        if (typeof (e.dataSeries.visible) === "undefined" || e.dataSeries.visible) {
            e.dataSeries.visible = false;
        } else {
            e.dataSeries.visible = true;
        }
        e.chart.render();
    }
    
    //CHARTJS
    /*
    var presets = window.chartColors;
    var utils = Sigechart.utils;

    var inputs = {
        min: 0,
        max: 100,
        count: 8,
        decimals: 2,
        continuity: 1
    };

    function generateData(config){
        return utils.numbers(Chart.helpers.merge(inputs, config || {}));
    }

    function generateLabels(config){
        return utils.months(Chart.helpers.merge({
            count: inputs.count,
            section: 3
        }, config || {}));
    }

    var options = {
        maintainAspectRatio: false,
        spanGaps: false,
        elements: {
            line: {
                tension: 0.1
            }
        },
        plugins: {
            filler: {
                propagate: false
            }
        },
        scales: {
            xAxes: [{
                ticks: {
                    autoSkip: false,
                    maxRotation: 0
                }
            }]
        }
    };

    ["ventas,gastos;3,4;0", "Aves Muertas;4;1"].forEach((conf, index)=>{
        var configs = conf.split(";");
        var labels = configs[0].split(",");
        var colors = configs[1].split(",");
        var tipo_chart = configs[2];

        console.log(colors)
        
        var dataSet = []
        //Generamos el dataset dependiendo de los labels
        labels.forEach((lbl, i)=>{
            dataSet.push({
                backgroundColor: utils.transparentize(utils.colores[colors[i]]),
                borderColor: utils.colores[colors[i]],
                data: generateData(),
                label: lbl,
                fill: 'start'
            })
        });
        new Chart('chart-' + index, {
            type: utils.tipoChart[tipo_chart],
            data: {
                labels: generateLabels(),
                datasets: dataSet
            },
            options: Chart.helpers.merge(options, {
                title: {
                    text: 'Producción',
                    display: false
                }
            })
        })
    })
    */
});