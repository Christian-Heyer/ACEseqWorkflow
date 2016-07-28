package de.dkfz.b080.co.files;

import de.dkfz.b080.co.aceseq.ACEseqConstants;
import de.dkfz.roddy.core.ExecutionContext;
import de.dkfz.roddy.execution.jobs.Job;
import de.dkfz.roddy.execution.jobs.JobResult;
import de.dkfz.roddy.knowledge.files.*;

import java.io.File;
import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/**
 * Created by michael on 11.06.14.
 */
public class UnphasedGenotypeFileGroupByChromosome extends IndexedFileObjects {

    private Map<String, UnphasedGenotypeFile> files;

    public UnphasedGenotypeFileGroupByChromosome(List<String> keyset, Map<String, UnphasedGenotypeFile> files, ExecutionContext context) {
        super(keyset, files, context);
        this.files = files;
    }

    public Map<String, UnphasedGenotypeFile> getFiles() {
        return files;
    }

    
}
