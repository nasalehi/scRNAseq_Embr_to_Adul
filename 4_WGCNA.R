load("monocle.RData")
library('WGCNA')
DefaultAssay(all.integrated) <- "integrated"
options(stringsAsFactors = F)

#nfeatures = 2000
datExpr <- t(as.matrix(GetAssayData(all.integrated)))
dim(datExpr)
head(datExpr)
powers = c(c(1:10), seq(from = 12, to=20, by=2))
sft = pickSoftThreshold(datExpr, powerVector = powers, verbose = 5)

# Plot the results:
sizeGrWindow(9, 5)
par(mfrow = c(1,2));
cex1 = 0.9;
# Scale-free topology fit index as a function of the soft-thresholding power
pdf("./Results/WGCNA/Scale-free.pdf")
plot(sft$fitIndices[,1], -sign(sft$fitIndices[,3])*sft$fitIndices[,2],
     xlab="Soft Threshold (power)",ylab="Scale Free Topology Model Fit,signed R^2",type="n",
     main = paste("Scale independence"));
text(sft$fitIndices[,1], -sign(sft$fitIndices[,3])*sft$fitIndices[,2],
     labels=powers,cex=cex1,col="red");
# this line corresponds to using an R^2 cut-off of h
abline(h=0.9,col="red")
# Mean connectivity as a function of the soft-thresholding power
plot(sft$fitIndices[,1], sft$fitIndices[,5],
     xlab="Soft Threshold (power)",ylab="Mean Connectivity", type="n",
     main = paste("Mean connectivity"))
text(sft$fitIndices[,1], sft$fitIndices[,5], labels=powers, cex=cex1,col="red")
dev.off()
####
#power = 5
net <- blockwiseModules(datExpr, power = 5,
                        corType = "pearson", 
                        networkType = "signed", minModuleSize = 30,
                        reassignThreshold = 0, mergeCutHeight = 0.25,
                        numericLabels = F, pamRespectsDendro = FALSE,
                        saveTOMs = TRUE,
                        saveTOMFileBase = "TOM_all",
                        verbose = 3)


table(net$colors)

moduleLabels = net$colors
moduleColors = labels2colors(moduleLabels)
MEs = net$MEs;
geneTree = net$dendrograms[[1]];

# Convert labels to colors for plotting
mergedColors = net$colors
# Plot the dendrogram and the module colors underneath
pdf("./Results/WGCNA/dendrogram_pearson.pdf")
plotDendroAndColors(net$dendrograms[[1]], mergedColors[net$blockGenes[[1]]],
                    "Module colors",
                    dendroLabels = FALSE, hang = 0.03,
                    addGuide = TRUE, guideHang = 0.05)
dev.off()

df <- data.frame(grey=colnames(datExpr)[net$colors == "grey"]) #notice I created a data.frame vs. the vector you called
blue=colnames(datExpr)[net$colors == "blue"]
brown=colnames(datExpr)[net$colors == "brown"]
green=colnames(datExpr)[net$colors == "green"]
turquoise=colnames(datExpr)[net$colors == "turquoise"]
red=colnames(datExpr)[net$colors == "red"]
yellow=colnames(datExpr)[net$colors == "yellow"]

#METHOD 1
df$blue <- c(blue, rep(NA, nrow(df)-length(blue)))#keep as integer
df$brown <- c(brown, rep(NA, nrow(df)-length(brown)))
df$green <- c(green, rep(NA, nrow(df)-length(green)))
df$turquoise <- c(turquoise, rep(NA, nrow(df)-length(turquoise)))
df$red <- c(red, rep(NA, nrow(df)-length(red)))
df$yellow <- c(yellow, rep(NA, nrow(df)-length(yellow)))
str(df) 

write.csv(df, "./Results/WGCNA/coE_Pearson.csv")

grey.eigengene <- unlist(net$MEs[paste0("ME", "grey")])
names(grey.eigengene) <- rownames(datExpr)
all.integrated$grey.eigengene <- grey.eigengene

blue.eigengene <- unlist(net$MEs[paste0("ME", "blue")])
names(blue.eigengene) <- rownames(datExpr)
all.integrated$blue.eigengene <- blue.eigengene

brown.eigengene <- unlist(net$MEs[paste0("ME", "brown")])
names(brown.eigengene) <- rownames(datExpr)
all.integrated$brown.eigengene <- brown.eigengene

green.eigengene <- unlist(net$MEs[paste0("ME", "green")])
names(green.eigengene) <- rownames(datExpr)
all.integrated$green.eigengene <- green.eigengene

turquoise.eigengene <- unlist(net$MEs[paste0("ME", "turquoise")])
names(turquoise.eigengene) <- rownames(datExpr)
all.integrated$turquoise.eigengene <- turquoise.eigengene

red.eigengene <- unlist(net$MEs[paste0("ME", "red")])
names(red.eigengene) <- rownames(datExpr)
all.integrated$red.eigengene <- red.eigengene

yellow.eigengene <- unlist(net$MEs[paste0("ME", "yellow")])
names(yellow.eigengene) <- rownames(datExpr)
all.integrated$yellow.eigengene <- yellow.eigengene

net$colors


pdf("./Results/WGCNA/FeaturePlot.pdf")
FeaturePlot(all.integrated, features = "blue.eigengene" ,cols = c("grey", "blue"))+
  theme(panel.background = element_rect(fill = "white", colour = "black"))
FeaturePlot(all.integrated, features ="brown.eigengene" ,cols = c("grey", "brown"))+
  theme(panel.background = element_rect(fill = "white", colour = "black"))
FeaturePlot(all.integrated, features ="green.eigengene",cols = c("grey","green"))+
  theme(panel.background = element_rect(fill = "white", colour = "black"))
FeaturePlot(all.integrated, features = "turquoise.eigengene" ,cols = c("grey", "turquoise"))+
  theme(panel.background = element_rect(fill = "white", colour = "black"))
FeaturePlot(all.integrated, features = "red.eigengene" ,cols = c("grey","red"))+
  theme(panel.background = element_rect(fill = "white", colour = "black"))
FeaturePlot(all.integrated, features = "yellow.eigengene" ,cols = c("grey","yellow"))+
  theme(panel.background = element_rect(fill = "white", colour = "black"))
FeaturePlot(all.integrated, features = "grey.eigengene" ,cols = c("grey","Orange"))+
  theme(panel.background = element_rect(fill = "white", colour = "black"))
dev.off()

modNames = substring(names(MEs), 3)

nGenes = ncol(datExpr)
nSamples = nrow(datExpr)
dissTOM = 1-TOMsimilarityFromExpr(datExpr, power = 7);
plotTOM = dissTOM^7;
diag(plotTOM) = NA;
sizeGrWindow(9,9)

pdf("./Results/WGCNA/heatmap.pdf")
TOMplot(plotTOM, geneTree, moduleColors, main = "Network heatmap plot, all genes")
dev.off()

# Recalculate module eigengenes
#MEs = moduleEigengenes(datExpr, moduleColors)$eigengenes
MET =MEs
sizeGrWindow(5,7.5);
par(cex = 0.9)
pdf("./Results/WGCNA/Eigengene.pdf")
plotEigengeneNetworks(MET, "", marDendro = c(0,4,1,2), marHeatmap = c(3,4,1,2), cex.lab = 0.8, xLabelsAngle
                      = 90)
dev.off()

sizeGrWindow(6,6);
par(cex = 1.0)
pdf("./Results/WGCNA/Eigengene_dendrogram.pdf")
plotEigengeneNetworks(MET, "Eigengene dendrogram", marDendro = c(0,4,2,0),
                      plotHeatmaps = FALSE)
dev.off()

par(cex = 1.0)
pdf("./Results/WGCNA/Eigengene_heatmap_5.pdf")
plotEigengeneNetworks(MET, "Eigengene adjacency heatmap", marHeatmap = c(3,4,2,2),
                      plotDendrograms = FALSE, xLabelsAngle = 90)
dev.off()

p1<-net$MEs
j1 <- max.col(p1, "first")
WGCNA <- names(p1)[j1]
Idents(all.integrated) <- WGCNA

pdf("./Results/WGCNA/FeaturePlot.pdf")
DimPlot(all.integrated, reduction = "umap", group.by = 'ident',label = TRUE, repel = TRUE, 
        cols= c("blue","green" ,"grey" , "brown", "turquoise", "red" , "yellow"))+ NoLegend()
dev.off()

f <- function(module){
  eigengene <- unlist(net$MEs[paste0("ME", module)])
  means <- tapply(eigengene, Idents(all.integrated), mean, na.rm = T)
  return(means)
}
modules <- c("blue", "brown", "green", "turquoise", "red","yellow")

Idents(all.integrated)<- class
pdf("./Results/WGCNA/clusters_WGCNA.pdf")
plotdat <- sapply(modules, f)
matplot(plotdat, col = modules, type = "l", lwd = 2, xaxt = "n", xlab = "Seurat Cluster",
        ylab = "WGCNA Module Eigengene")
axis(1, at = 1:18, labels = 1:18, cex.axis = 0.8)
matpoints(plotdat, col = modules, pch = 21)
dev.off()


TOM = TOMsimilarityFromExpr(datExpr, power = 5);
modules <- c("blue", "brown", "green", "turquoise", "red","yellow")
probes = colnames(datExpr)
inModule = is.finite(match(moduleLabels , modules));
modProbes = probes[inModule];
#modGenes = annot$gene_symbol[match(modProbes, annot$substanceBXH)];
# Select the corresponding Topological Overlap
modTOM = TOM[inModule, inModule];
dimnames(modTOM) = list(modProbes, modProbes)
# Export the network into edge and node list files Cytoscape can read
moduleColors=moduleLabels
cyt = exportNetworkToCytoscape(modTOM,
                               edgeFile = paste("./CytoscapeInput-edges_", paste(modules, collapse="-"), ".txt", sep=""),
                               nodeFile = paste("./CytoscapeInput-nodes_", paste(modules, collapse="-"), ".txt", sep=""),
                               weighted = TRUE,
                               threshold = 0.02,
                               nodeNames = modProbes,
                               nodeAttr = moduleColors[inModule]);
                               
save.image(file = "WGCNA.RData")                               
