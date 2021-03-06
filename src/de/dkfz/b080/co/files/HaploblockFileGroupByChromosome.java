/*
 * Copyright (c) 2017 The ACEseq workflow developers.
 *
 * Distributed under the MIT License (license terms are at https://www.github.com/eilslabs/ACEseqWorkflow/LICENSE.txt).
 */

package de.dkfz.b080.co.files;

import de.dkfz.roddy.knowledge.files.FileGroup;

import java.util.LinkedList;
import java.util.Map;

/**
 * Created by michael on 11.06.14.
 */
public class HaploblockFileGroupByChromosome extends FileGroup {

    private Map<String, HaploblockGroupFile> files;

    public HaploblockFileGroupByChromosome(Map<String, HaploblockGroupFile> files) {
        super(new LinkedList<>(files.values()));
        this.files = files;
    }

    public Map<String, HaploblockGroupFile> getFiles() {
        return files;
    }

}
